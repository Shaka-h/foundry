// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {DiscussionContract} from "../src/DiscussionContract.sol";


contract DeployDiscussion is Script {
    function run() external returns (DiscussionContract){
        vm.startBroadcast();
        address discussionContractAddress = 0x5FbDB2315678afecb367f032d93F642f64180aa3; // Replace with an actual tweet contract address
        address profileContract = 0x5FbDB2315678afecb367f032d93F642f64180aa3; // Replace with an actual tweet contract address

        DiscussionContract discussionContract = new DiscussionContract(discussionContractAddress, profileContract);

        vm.stopBroadcast();

        return discussionContract;
    }
}