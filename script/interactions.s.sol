// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import {ProfileFactory} from "../src/ProfileFactory.sol";
import {DevOpsTools} from "../lib/foundry-devops/src/DevOpsTools.sol";


contract FundFundMe is Script {
    function fundFundMe(address mostRecentlyDeployed) public {
        console.log(mostRecentlyDeployed);
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("ProfileFactory", block.chainid);
        fundFundMe(mostRecentlyDeployed);
    }
}


// contract DeployProfileFactory is Script {
//     function run() external returns (ProfileFactory){
//         vm.startBroadcast();

//         ProfileFactory profileContract = new ProfileFactory();

//         address tweetContractAddress = 0x5FbDB2315678afecb367f032d93F642f64180aa3; // Replace with an actual tweet contract address
//         string memory username = "shaka";
//         string memory profileUrl = "Miriam Steven Shaka";

//         console.log("New ProfileFactory Contract Address:", profileContract.getprofileByAddressOwner().ProfileContract);
                
//         address newProfileAddress = profileContract.deployNFTProfileContract(tweetContractAddress, username, profileUrl);

//         console.log("New Profile Contract Address:", newProfileAddress);

//         ProfileFactory.MyNFTProfile memory profile = profileContract.getprofileByAddressContract(newProfileAddress);

//         console.log("Profile owner:", profile.owner);
//         console.log("Profile ProfileContract:", profile.ProfileContract);
//         console.log("Profile username:", profile.username);
//         console.log("Profile profileUrl:", profile.profileUrl);
//         console.log("Profile time:", profile.time);



//         vm.stopBroadcast();
        
//         return profileContract;
//     }
// }


