// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {TutorialGround} from "../src/TutorialGround.sol";

contract DeployTutorialGround is Script {
    function run() external returns (TutorialGround) {
        vm.startBroadcast();

        TutorialGround tutorialGroundContract = new TutorialGround();

        vm.stopBroadcast();

        return tutorialGroundContract;
    }
}
