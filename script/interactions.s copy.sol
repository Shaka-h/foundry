// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import {ProfileFactory} from "../src/ProfileFactory.sol";

contract DeployProfileScript is Script {
    function run() external {
        // Address of the deployed ProfileFactory contract
        address factoryContractAddress = 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512; // Update to your actual contract address

        // Initialize the contract interface
        ProfileFactory profileFactory = ProfileFactory(factoryContractAddress);

        // Parameters for the profile contract deployment
        address tweetContractAddress = 0x5FbDB2315678afecb367f032d93F642f64180aa3; // Replace with an actual tweet contract address
        address discussionContract_Address = 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0; // Replace with an actual discussionContract_Address
        string memory username = "shaka";
        string memory profileUrl = "Miriam Shaka";

        // Start broadcasting transactions
        vm.startBroadcast();

        // Call the function to deploy the profile contract
        address newProfileAddress = profileFactory.deployNFTProfileContract(tweetContractAddress, discussionContract_Address, username, profileUrl);

        // Log the new profile contract address
        console.log("New Profile Contract Address:", newProfileAddress);

        // Stop broadcasting transactions
        vm.stopBroadcast();
    }
}

// contract profileByAddress is Script {
//     function run() external {
//         // Address of the deployed ProfileFactory contract
//         address profileContract = 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512;

//         // Initialize the contract interface
//         ProfileFactory profileFactory = ProfileFactory(profileContract);

//         // Example profile contract address to query
//         address profileContractAddress = 0xCafac3dD18aC6c6e92c921884f9E4176737C052c; // Replace with an actual profile contract address

//         // Start broadcasting transactions
//         vm.startBroadcast();

//         // Call the function to get the profile by contract address
//         ProfileFactory.MyNFTProfile memory profile = profileFactory.getprofileByAddressContract(profileContractAddress);

//         // Log the profile details
//         console.log("Profile owner:", profile.owner);
//         console.log("Profile ProfileContract:", profile.ProfileContract);
//         console.log("Profile username:", profile.username);
//         console.log("Profile profileUrl:", profile.profileUrl);
//         console.log("Profile time:", profile.time);

//         // Stop broadcasting transactions
//         vm.stopBroadcast();
//     }
// }
