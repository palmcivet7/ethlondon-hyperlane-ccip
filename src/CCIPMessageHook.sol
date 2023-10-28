// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

// import {IPostDispatchHook} from "@hyperlane-xyz/core/contracts/interfaces/hooks/IPostDispatchHook.sol";
import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
// import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {AbstractMessageIdAuthHook} from "@hyperlane-xyz/core/contracts/hooks/libs/AbstractMessageIdAuthHook.sol";
import {IMailbox} from "@hyperlane-xyz/core/contracts/interfaces/IMailbox.sol";

contract CCIPMessageHook is AbstractMessageIdAuthHook {
    error CCIPMessageHook__NoValueSent();
    error CCIPMessageHook__NotEnoughPayment(uint256 valueSent, uint256 calculatedFees);

    IRouterClient public router;
    uint64 public destinationChainSelector;

    constructor(address _router, uint64 _destinationChainSelector, uint32 _destinationDomain, address _mailbox)
        AbstractMessageIdAuthHook(_mailbox, _destinationDomain, bytes32(0))
    {
        router = IRouterClient(_router);
        destinationChainSelector = _destinationChainSelector;
        destinationDomain = _destinationDomain;
        mailbox = IMailbox(_mailbox);
    }

    /**
     * @notice Post action after a message is dispatched via the Mailbox
     * param metadata The metadata required for the hook
     * @param message The message passed from the Mailbox.dispatch() call
     */
    function postDispatch(
        bytes calldata,
        /*metadata*/
        bytes calldata message
    ) external payable override {
        if (msg.value == 0) revert CCIPMessageHook__NoValueSent();

        Client.EVM2AnyMessage memory evm2AnyMessage = Client.EVM2AnyMessage({
            receiver: abi.encode(ism),
            data: message,
            tokenAmounts: new Client.EVMTokenAmount[](0),
            extraArgs: "",
            feeToken: address(0)
        });

        uint64 _destinationChainSelector = destinationChainSelector;

        uint256 fees = router.getFee(_destinationChainSelector, evm2AnyMessage);
        if (msg.value < fees) revert CCIPMessageHook__NotEnoughPayment(msg.value, fees);

        // If the sender has sent more than the required fee, refund the excess.
        uint256 excess = msg.value - fees;
        if (excess > 0) {
            payable(msg.sender).transfer(excess);
        }

        router.ccipSend(_destinationChainSelector, evm2AnyMessage);
    }

    /**
     * @notice Compute the payment required by the postDispatch call
     * param metadata The metadata required for the hook
     * @param message The message passed from the Mailbox.dispatch() call
     * @return Quoted payment for the postDispatch call
     */
    function quoteDispatch(
        bytes calldata,
        /*metadata*/
        bytes calldata message
    ) public view override returns (uint256) {
        Client.EVM2AnyMessage memory evm2AnyMessage = Client.EVM2AnyMessage({
            receiver: abi.encode(ism),
            data: message,
            tokenAmounts: new Client.EVMTokenAmount[](0),
            extraArgs: "",
            feeToken: address(0) // Since we are paying in native
        });

        return router.getFee(destinationChainSelector, evm2AnyMessage);
    }

    /**
     * @notice Quote dispatch hook implementation.
     * param metadata The metadata of the message being dispatched.
     * @param message The message being dispatched.
     * @return The quote for the dispatch.
     */
    function _quoteDispatch(bytes calldata metadata, bytes calldata message) internal view override returns (uint256) {
        quoteDispatch(metadata, message);
    }

    function _sendMessageId(
        bytes calldata,
        /*metadata*/
        bytes memory payload
    ) internal override {
        mailbox.dispatch(destinationDomain, ism, payload);
    }

    ///////// Setter Functions /////////////

    function setIsm(bytes32 _ism) public onlyOwner {
        ism = _ism;
    }

    function setDestinationChainSelector(uint64 _destinationChainSelector) public onlyOwner {
        destinationChainSelector = _destinationChainSelector;
    }
}
