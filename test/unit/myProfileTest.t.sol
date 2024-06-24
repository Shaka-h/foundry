// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {MyProfile} from "../../src/MyProfile.sol";
import {PostContract} from "../../src/PostContract.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract MyProfileTest is Test {
    MyProfile myProfile;
    PostContract myPost;
    address tweetContractAddress = address(0x123);    
    address discussionContract_Address = address(0x126);
    address discussionContract_Address2 = address(0x125);
    address testUser = address(0x456);

    function setUp() public {
        // Deploy the MyProfile contract
        myPost = new PostContract(tweetContractAddress, testUser);
        myProfile = new MyProfile(tweetContractAddress, discussionContract_Address, "testUser", "https://profile.url");
    }

    function testCreatePost() public {
        // Start impersonating testUser
        vm.startPrank(testUser);

        // Define the post URI
        string memory postURI = "https://post.uri";

        // Create a new post
        uint256 newPostId = myPost.createPost(postURI);

        // Check if the postId is correct
        assertEq(newPostId, 1, "New post ID should be 1");

        // Check if the post URI is stored correctly
        assertEq(myPost.tokenURI(newPostId), postURI, "Post URI should match the provided URI");

        // Check if the post is added to the allProfilePosts array
        string memory storedPostURI = myPost.allProfilePosts(0);
        assertEq(storedPostURI, postURI, "Stored post URI should match the provided URI");

        // Check if the approval is set correctly
        assertTrue(myPost.isApprovedForAll(testUser, tweetContractAddress), "Tweet contract should have approval");

        // Stop impersonating testUser
        vm.stopPrank();
    }

    function testGetAllPosts() public {
        // Start impersonating testUser
        vm.startPrank(testUser);

        // Create a new post
        string memory postURI1 = "https://post1.uri";
        myPost.createPost(postURI1);

        // Create another new post
        string memory postURI2 = "https://post2.uri";
        myPost.createPost(postURI2);

        // Get all posts
        string[] memory allPosts = myPost.getAllPosts();

        // Check if all posts are returned correctly
        assertEq(allPosts.length, 2, "Should return 2 posts");
        assertEq(allPosts[0], postURI1, "First post URI should match the provided URI");
        assertEq(allPosts[1], postURI2, "Second post URI should match the provided URI");

        // Stop impersonating testUser
        vm.stopPrank();
    }

    function testGetPostsURIById() public {
        // Start impersonating testUser
        vm.startPrank(testUser);

        // Create a new post
        string memory postURI1 = "https://post1.uri";
        uint256 postId1 = myPost.createPost(postURI1);

        // Create another new post
        string memory postURI2 = "https://post2.uri";
        uint256 postId2 = myPost.createPost(postURI2);

        // Get post URI by ID
        string memory retrievedPostURI1 = myPost.getPostsURIById(postId1);
        string memory retrievedPostURI2 = myPost.getPostsURIById(postId2);

        // Check if the post URIs are returned correctly by ID
        assertEq(retrievedPostURI1, postURI1, "Post URI for first post ID should match the provided URI");
        assertEq(retrievedPostURI2, postURI2, "Post URI for second post ID should match the provided URI");

        // Stop impersonating testUser
        vm.stopPrank();
    }
}
