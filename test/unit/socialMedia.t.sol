// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {AlphaConnect} from "../../src/socialMedia.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract MockERC721 is ERC721URIStorage {
    uint256 private _tokenIdCounter;

    constructor() ERC721("MockERC721", "MERC721") {}

    function mint(address to, string memory uri) public {
        uint256 tokenId = _tokenIdCounter;
        _tokenIdCounter += 1;
        _mint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }
}

contract AlphaConnectTest is Test {
    AlphaConnect public alphaConnect;
    MockERC721 public mockERC721;
    address public testUser1 = address(0x123);
    address public testUser2 = address(0x456);

    function setUp() public {
        // Deploy the contracts
        alphaConnect = new AlphaConnect();
        mockERC721 = new MockERC721();

        // Mint an NFT for testUser1
        mockERC721.mint(testUser1, "https://token-uri.com/1");

        // Mint an NFT for testUser2
        mockERC721.mint(testUser2, "https://token-uri.com/2");
    }

    function testCreatePost() public {
        // Start impersonating testUser1
        vm.startPrank(testUser1);

        // Approve AlphaConnect contract to transfer the NFT
        mockERC721.approve(address(alphaConnect), 0);

        // Create a post
        alphaConnect.createPost(address(mockERC721), 0);

        // Fetch the created post
        AlphaConnect.Post[] memory posts = alphaConnect.fetchMyPostsCreated();
        assertEq(posts.length, 1, "Post count should be 1");
        assertEq(posts[0].creator, testUser1, "Post creator should be testUser1");

        // Stop impersonating testUser1
        vm.stopPrank();
    }

    function testCommentPost() public {
        // Start impersonating testUser1
        vm.startPrank(testUser1);

        // Approve AlphaConnect contract to transfer the NFT
        mockERC721.approve(address(alphaConnect), 0);

        // Create a post
        alphaConnect.createPost(address(mockERC721), 0);

        // Stop impersonating testUser1
        vm.stopPrank();

        // Start impersonating testUser2
        vm.startPrank(testUser2);

        // Comment on the post
        alphaConnect.commentPost(1, "https://comment-uri.com/1");

        // Fetch the comments of the post
        AlphaConnect.Comment[] memory comments = alphaConnect.getAllCommentsMadeToPost(1);
        assertEq(comments.length, 1, "Comment count should be 1");
        assertEq(comments[0].commentor, testUser2, "Commentor should be testUser2");

        // Stop impersonating testUser2
        vm.stopPrank();
    }

    function testLikePost() public {
        // Start impersonating testUser1
        vm.startPrank(testUser1);

        // Approve AlphaConnect contract to transfer the NFT
        mockERC721.approve(address(alphaConnect), 0);

        // Create a post
        alphaConnect.createPost(address(mockERC721), 0);

        // Stop impersonating testUser1
        vm.stopPrank();

        // Start impersonating testUser2
        vm.startPrank(testUser2);

        // Like the post
        alphaConnect.likePost(1);

        // Fetch the post
        AlphaConnect.Post[] memory posts = alphaConnect.fetchAllPostsCreated();
        assertEq(posts[0].like, 1, "Like count should be 1");

        // Stop impersonating testUser2
        vm.stopPrank();
    }

    function testUnLikePost() public {
        // Start impersonating testUser1
        vm.startPrank(testUser1);

        // Approve AlphaConnect contract to transfer the NFT
        mockERC721.approve(address(alphaConnect), 0);

        // Create a post
        alphaConnect.createPost(address(mockERC721), 0);

        // Stop impersonating testUser1
        vm.stopPrank();

        // Start impersonating testUser2
        vm.startPrank(testUser2);

        // Like the post
        alphaConnect.likePost(1);
        // Unlike the post
        alphaConnect.unLikePost(1);

        // Fetch the post
        AlphaConnect.Post[] memory posts = alphaConnect.fetchAllPostsCreated();
        assertEq(posts[0].like, 0, "Like count should be 0");
        assertEq(posts[0].dislike, 1, "Dislike count should be 1");

        // Stop impersonating testUser2
        vm.stopPrank();
    }

    function testCreateNews() public {
        // Start impersonating the admin
        vm.startPrank(alphaConnect.admin());

        // Create news
        alphaConnect.createNews("https://news-url.com/1");

        // Fetch the created news
        AlphaConnect.News[] memory newsList = alphaConnect.getAllPublishedNews();
        assertEq(newsList.length, 1, "News count should be 1");
        assertEq(newsList[0].newsUrl, "https://news-url.com/1", "News URL should match");

        // Stop impersonating the admin
        vm.stopPrank();
    }

    function testUpdateNews() public {
        // Start impersonating the admin
        vm.startPrank(alphaConnect.admin());

        // Create news
        alphaConnect.createNews("https://news-url.com/1");

        // Update the news
        alphaConnect.updateNews(1, "https://updated-news-url.com/1");

        // Fetch the updated news
        (uint256 newsId, string memory newsUrl,,) = alphaConnect.getNews(1);
        assertEq(newsUrl, "https://updated-news-url.com/1", "Updated News URL should match");

        // Stop impersonating the admin
        vm.stopPrank();
    }

    function testDeleteNews() public {
        // Start impersonating the admin
        vm.startPrank(alphaConnect.admin());

        // Create news
        alphaConnect.createNews("https://news-url.com/1");

        // Delete the news
        alphaConnect.deleteNews(1);

        // Fetch the published news
        AlphaConnect.News[] memory newsList = alphaConnect.getAllPublishedNews();
        assertEq(newsList.length, 0, "Published news count should be 0");

        // Stop impersonating the admin
        vm.stopPrank();
    }
}
