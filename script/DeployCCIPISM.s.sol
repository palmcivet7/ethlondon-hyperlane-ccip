// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

import {Script} from "forge-std/Script.sol";
import {CCIPISM} from "../src/CCIPISM.sol";

contract DeployCCIPISM is Script {
    // from https://docs.chain.link/ccip/supported-networks#avalanche-fuji
    address fujiRouterAddress = 0x554472a2720E5E7D5D3C817529aBA05EEd5F82D8;
    address hook = 0xE0b1b6692dFA4D2a9CD189cd5Cd8B682d31B108C; // retrieved from deployed hook

    function run() external returns (CCIPISM) {
        vm.startBroadcast();
        CCIPISM ccipIsm = new CCIPISM(fujiRouterAddress);
        vm.stopBroadcast();
        return (ccipIsm);
    }
}
