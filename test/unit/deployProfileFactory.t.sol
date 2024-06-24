// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ProfileFactory} from "../../src/ProfileFactory.sol";
import {MyProfile} from "../../src/ProfileFactory.sol";
import {Test, console} from "forge-std/Test.sol";
import {DeployProfileFactory} from "../../script/deployProfileFactory.s.sol";

contract ProfileFactoryTest is Test {
    ProfileFactory profileFactory;
    address discussionContract_Address1 = address(0x126);
    address discussionContract_Address2 = address(0x125);
    address tweetContractAddress1 = address(0x123);
    address tweetContractAddress2 = address(0x124);
    address testUser1 = address(0x456);
    address testUser2 = address(0x789);

    function setUp() public {
        // Deploy the ProfileFactory contract using my deployFactory script
        DeployProfileFactory deployProfileFactory = new DeployProfileFactory();
        profileFactory = deployProfileFactory.run();
    }

    function testDeployNFTProfileContract() public {
        // Start impersonating testUser1
        vm.startPrank(testUser1);

        // Deploy a new NFT profile
        string memory username = "testUser1";
        string memory profileUrl = "https://profile1.url";
        address profileContract = profileFactory.deployNFTProfileContract(tweetContractAddress1, discussionContract_Address1, username, profileUrl);

        // Verify the profile was deployed correctly
        ProfileFactory.MyNFTProfile memory profile = profileFactory.getprofileByAddressContract(profileContract);
        assertEq(profile.owner, testUser1, "Owner should be testUser1");
        assertEq(profile.username, username, "Username should be testUser1");
        assertEq(profile.profileUrl, profileUrl, "Profile URL should match");

        // Stop impersonating testUser1
        vm.stopPrank();
    }

 

    // function testGetProfileByUsername() public {
    //     // Start impersonating testUser1
    //     vm.startPrank(testUser1);

    //     // Deploy a new NFT profile
    //     string memory username = "testUser1";
    //     string memory profileUrl = "https://profile1.url";
    //     profileFactory.deployNFTProfileContract(tweetContractAddress1, discussionContract_Address1, username, profileUrl);

    //     // Retrieve profile by username
    //     ProfileFactory.MyNFTProfile memory profile = profileFactory.getprofileByUsername(username);
    //     assertEq(profile.owner, testUser1, "Owner should be testUser1");
    //     assertEq(profile.username, username, "Username should be testUser1");
    //     assertEq(profile.profileUrl, profileUrl, "Profile URL should match");

    //     // Stop impersonating testUser1
    //     vm.stopPrank();
    // }

    function testFollowProfile() public {
        // Start impersonating testUser1
        vm.startPrank(testUser1);

        // Deploy a new NFT profile for testUser1
        string memory username1 = "testUser1";
        string memory profileUrl1 = "https://profile1.url";
        address profileContract1 =
            profileFactory.deployNFTProfileContract(tweetContractAddress1, discussionContract_Address1, username1, profileUrl1);

        // Stop impersonating testUser1
        vm.stopPrank();

        // Start impersonating testUser2
        vm.startPrank(testUser2);

        // Deploy a new NFT profile for testUser2
        string memory username2 = "testUser2";
        string memory profileUrl2 = "https://profile1.url";
        profileFactory.deployNFTProfileContract(tweetContractAddress2, discussionContract_Address2, username2, profileUrl2);

        profileFactory.followProfile(profileContract1);
        assertTrue(
            profileFactory.isFollowingProfile(testUser2, testUser1), "testUser2 should be following testUser1's profile"
        );

        // Retrieve followers of testUser1's profile
        address[] memory followers = profileFactory.getAllfollowers(testUser1);
        assertEq(followers.length, 1, "There should be 1 follower");
        assertEq(followers[0], testUser2, "Follower should be testUser2");

        // Retrieve following profiles of testUser2
        address[] memory following = profileFactory.getAllfollowing(testUser2);
        assertEq(following.length, 1, "There should be 1 following profile");
        assertEq(following[0], testUser1, "Following profile should be testUser1");

        // Stop impersonating testUser2
        vm.stopPrank();
    }

    function testShareCard() public {
        // Start impersonating testUser1
        vm.startPrank(testUser1);

        // Deploy a new NFT profile for testUser1
        string memory username1 = "testUser1";
        string memory profileUrl1 = "https://profile1.url";
        address profileContract1 =
            profileFactory.deployNFTProfileContract(tweetContractAddress1, discussionContract_Address1, username1, profileUrl1);

        // Stop impersonating testUser1
        vm.stopPrank();

        // Start impersonating testUser2
        vm.startPrank(testUser2);

        // Deploy a new NFT profile for testUser2
        string memory username2 = "testUser2";
        string memory profileUrl2 = "https://profile2.url";
        profileFactory.deployNFTProfileContract(tweetContractAddress2, discussionContract_Address2, username2, profileUrl2);

        // Share business card with testUser1's profile
        profileFactory.shareCard(profileContract1);
        vm.stopPrank();

        vm.startPrank(testUser1);
        // Retrieve business cards received by testUser1
        address[] memory cards = profileFactory.getMybusinessCard();
        assertEq(cards.length, 1, "There should be 1 business card");
        assertEq(cards[0], testUser2, "Business card should be from testUser2");

        // Stop impersonating testUser2
        vm.stopPrank();
    }

    function testIsFollowing() public {
        // Start impersonating testUser1
        vm.startPrank(testUser1);

        // Deploy a new NFT profile for testUser1
        string memory username1 = "testUser1";
        string memory profileUrl1 = "https://profile1.url";
        address profileContract1 =
            profileFactory.deployNFTProfileContract(tweetContractAddress1, discussionContract_Address1, username1, profileUrl1);

        // Stop impersonating testUser1
        vm.stopPrank();

        // Start impersonating testUser2
        vm.startPrank(testUser2);

        // Deploy a new NFT profile for testUser2
        string memory username2 = "testUser2";
        string memory profileUrl2 = "https://profile1.url";
        profileFactory.deployNFTProfileContract(tweetContractAddress2, discussionContract_Address2, username2, profileUrl2);

        profileFactory.followProfile(profileContract1);
        assertTrue(
            profileFactory.isFollowingProfile(testUser2, testUser1),
            "testUser2 should be following testUser1's profile, following not working"
        );

        // Stop impersonating testUser2
        vm.stopPrank();
    }

    // function testGetProfileByContractAddress() public {
    //     // Start impersonating testUser1
    //     vm.startPrank(testUser1);

    //     // Deploy a new NFT profile
    //     string memory username = "testUser1";
    //     string memory profileUrl = "https://profile1.url";
    //     address contractAddress = profileFactory.deployNFTProfileContract(tweetContractAddress1, discussionContract_Address1, username, profileUrl);

    //     // Retrieve profile by username
    //     ProfileFactory.MyNFTProfile memory profileByAddress =
    //         profileFactory.getprofileByAddressContract(contractAddress);
    //     ProfileFactory.MyNFTProfile memory profileByUsername = profileFactory.getprofileByUsername(username);

    //     assertEq(profileByAddress.owner, profileByUsername.owner, "profileByAddress does not match profileByUsername");

    //     // Stop impersonating testUser1
    //     vm.stopPrank();
    // }
}
