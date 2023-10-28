// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

import {Script} from "forge-std/Script.sol";
import {CCIPMessageHook} from "../src/CCIPMessageHook.sol";

contract DeployCCIPMessageHook is Script {
    // from https://docs.chain.link/ccip/supported-networks#ethereum-sepolia
    address sepoliaRouterAddress = 0xD0daae2231E9CB96b94C8512223533293C3693Bf;
    uint64 fujiChainSelector = 14767482510784806043;

    function run() external returns (CCIPMessageHook) {
        vm.startBroadcast();
        CCIPMessageHook ccipHook = new CCIPMessageHook(sepoliaRouterAddress, fujiChainSelector);
        vm.stopBroadcast();
        return (ccipHook);
    }
}
