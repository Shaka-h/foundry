// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {ProfileFactory} from "../src/ProfileFactory.sol";


contract DeployProfileFactory is Script {
    function run() external returns (ProfileFactory){
        vm.startBroadcast();

        ProfileFactory profileContract = new ProfileFactory();

        vm.stopBroadcast();

        return profileContract;
    }
}