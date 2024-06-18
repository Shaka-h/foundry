// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {Discussions} from "../src/Discussion.sol";


contract DeployDiscussion is Script {
    function run() external returns (Discussions){
        vm.startBroadcast();

        Discussions discussionContract = new Discussions();

        vm.stopBroadcast();

        return discussionContract;
    }
}