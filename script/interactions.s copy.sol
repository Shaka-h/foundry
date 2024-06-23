// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import {ProfileFactory} from "../src/ProfileFactory.sol";
import {DevOpsTools} from "../lib/foundry-devops/src/DevOpsTools.sol";

contract DeployProfileFactory is Script {
    function run() external returns (ProfileFactory) {
        vm.startBroadcast();

        ProfileFactory profileContract = new ProfileFactory();

        address tweetContractAddress = 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512; // Replace with an actual tweet contract address
        string memory username = "shaka";
        string memory profileUrl = "QmeuQj2qCPTXHp2xHSgaB2hTNajReKm4LUqjWroBBFbp7b";

        console.log("New ProfileFactory Contract Address:", profileContract.getprofileByAddressOwner().ProfileContract);

        address newProfileAddress = profileContract.deployNFTProfileContract(tweetContractAddress, username, profileUrl);

        console.log("New Profile Contract Address:", newProfileAddress);

        ProfileFactory.MyNFTProfile memory profile = profileContract.getprofileByAddressContract(newProfileAddress);

        console.log("Profile owner:", profile.owner);
        console.log("Profile ProfileContract:", profile.ProfileContract);
        console.log("Profile username:", profile.username);
        console.log("Profile profileUrl:", profile.profileUrl);
        console.log("Profile time:", profile.time);

        vm.stopBroadcast();

        return profileContract;
    }
}

contract profileByAddress is Script {
       function run() external {
        // Address of the deployed ProfileFactory contract
        address profileContract = 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512;

        // Initialize the contract interface
        ProfileFactory profileFactory = ProfileFactory(profileContract);

        // Example profile contract address to query
        address profileContractAddress = 0xCafac3dD18aC6c6e92c921884f9E4176737C052c; // Replace with an actual profile contract address

        // Start broadcasting transactions
        vm.startBroadcast();

        // Call the function to get the profile by contract address
        ProfileFactory.MyNFTProfile memory profile = profileFactory
            .getprofileByAddressContract(profileContractAddress);

        // Log the profile details
        console.log("Profile owner:", profile.owner);
        console.log("Profile ProfileContract:", profile.ProfileContract);
        console.log("Profile username:", profile.username);
        console.log("Profile profileUrl:", profile.profileUrl);
        console.log("Profile time:", profile.time);

        // Stop broadcasting transactions
        vm.stopBroadcast();
    }
}
