// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import {CCIPReceiver} from "@chainlink/contracts-ccip/src/v0.8/ccip/applications/CCIPReceiver.sol";
import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {IInterchainSecurityModule} from "@hyperlane-xyz/core/contracts/interfaces/IInterchainSecurityModule.sol";
import {AbstractMessageIdAuthorizedIsm} from
    "@hyperlane-xyz/core/contracts/isms/hook/AbstractMessageIdAuthorizedIsm.sol";
import {LibBit} from "@hyperlane-xyz/core/contracts/libs/LibBit.sol";

contract CCIPISM is CCIPReceiver, Ownable, AbstractMessageIdAuthorizedIsm {
    error CCIPISM__InvalidHook();

    using LibBit for uint256;

    IRouterClient public router;
    address public hook;

    constructor(address _router, address _hook) CCIPReceiver(_router) {
        router = IRouterClient(_router);
        hook = _hook;
    }

    function _ccipReceive(Client.Any2EVMMessage memory any2EvmMessage) internal override {
        bytes32 messageId = bytes32(any2EvmMessage.data);
        verifiedMessages[messageId] = msg.value.setBit(VERIFIED_MASK_INDEX);
    }

    function verifyMessageId(bytes32 messageId) external payable override {
        if (_isAuthorized() == false) revert CCIPISM__InvalidHook();
        verifiedMessages[messageId] = msg.value.setBit(VERIFIED_MASK_INDEX);
    }

    function moduleType() external pure override returns (uint8) {
        return uint8(IInterchainSecurityModule.Types.UNUSED);
    }

    function _isAuthorized() internal view override returns (bool) {
        if (msg.sender == hook) {
            return true;
        }
        return false;
    }
}
