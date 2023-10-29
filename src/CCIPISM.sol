// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import {CCIPReceiver} from "@chainlink/contracts-ccip/src/v0.8/ccip/applications/CCIPReceiver.sol";
import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {IInterchainSecurityModule} from "@hyperlane-xyz/core/contracts/interfaces/IInterchainSecurityModule.sol";

contract CCIPISM is CCIPReceiver {
    mapping(bytes => bool) public verifiedMessages;

    IRouterClient public router;

    constructor(address _router) CCIPReceiver(_router) {
        router = IRouterClient(_router);
    }

    function _ccipReceive(Client.Any2EVMMessage memory any2EvmMessage) internal override {
        bytes memory messageId = any2EvmMessage.data;
        verifiedMessages[messageId] = true;
    }

    function verify(bytes calldata, /* _metadata */ bytes calldata _message) external view returns (bool) {
        return verifiedMessages[_message];
    }

    function moduleType() external pure returns (uint8) {
        return 0;
    }
}
