// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract PostContract is ERC721URIStorage {
    // Payable fallback function
    fallback() external payable {}

    // Payable receive function (Solidity version >= 0.6.0)
    receive() external payable {}
    
    using Counters for Counters.Counter;
    Counters.Counter private _postIds;

    address public profileContract;
    string public profileUrl;
    address public tweetContractAddress;

    string[] public allProfileDiscussions;
    string[] public allProfilePosts;
    mapping (uint256 => string) profileURIById;

    event postCreated(string profileURI, uint256 profileId, uint256 time);
    event discussionCreated(string profileURI, uint256 profileId, uint256 time);

    constructor(address _tweetContractAddress, address _profileContract) ERC721("eGa", "eGa") {
        tweetContractAddress = _tweetContractAddress;
        profileContract = _profileContract;
    }


    function createPost(string memory postURI) public returns (uint) {
        _postIds.increment(); // Increment the profile ID counter
        uint256 newPostId = _postIds.current(); // Get the new profile ID

        _mint(msg.sender, newPostId); // Mint the profile to the caller
        _setTokenURI(newPostId, postURI); // Set the profile URI

        allProfilePosts.push(postURI); // Add the new post ID to the array
        profileURIById[newPostId] = postURI; // Store the profile URI in the mapping
        setApprovalForAll(tweetContractAddress, true); //grant transaction permission to marketplace
        emit postCreated(postURI, newPostId, block.timestamp);

        return newPostId; // Return the new profile ID
    }

    function getAllPosts() external view returns (string[] memory) {
        return allProfilePosts; 
    }

    function getPostsURIById (uint256 profileId) external view returns (string memory) {
        return profileURIById[profileId];
    }
}


