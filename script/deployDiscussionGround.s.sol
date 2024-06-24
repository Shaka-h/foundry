// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {DiscussionGround} from "../src/DiscussionGround.sol";

contract DeployDiscussionGround is Script {
    function run() external returns (DiscussionGround) {
        vm.startBroadcast();

        DiscussionGround discussionGroundContract = new DiscussionGround();

        vm.stopBroadcast();

        return discussionGroundContract;
    }
}
