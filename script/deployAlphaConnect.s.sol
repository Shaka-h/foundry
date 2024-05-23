// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {AlphaConnect} from "../src/socialMedia.sol";

contract DeployAlphaConnect is Script {
    function run() external returns (AlphaConnect) {
        vm.startBroadcast();

        AlphaConnect alphaConnectContract = new AlphaConnect();

        vm.stopBroadcast();

        return alphaConnectContract;
    }
}
