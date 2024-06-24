// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract MyProfile is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    string public username;
    string public profileUrl;
    address public tweetContractAddress;
    address public discussionContractAddress;

    enum TokenType { POST, DISCUSSION }

    struct ProfileToken {
        TokenType tokenType;
        string uri;
    }

    ProfileToken[] public allProfilePosts;
    ProfileToken[] public allProfileDiscussions;
    mapping(uint256 => ProfileToken) public profileTokens;

    event PostCreated(string profileURI, uint256 tokenId, uint256 time);
    event DiscussionCreated(string profileURI, uint256 tokenId, uint256 time);

    constructor(address _tweetContractAddress, address _discussionContractAddress, string memory _username, string memory _profileUrl) 
        ERC721("eGa", "eGa") {
        tweetContractAddress = _tweetContractAddress;
        discussionContractAddress = _discussionContractAddress;
        username = _username;
        profileUrl = _profileUrl;
    }

    function createPost(string memory postURI) public returns (uint256) {
        _tokenIds.increment();
        uint256 newPostId = _tokenIds.current();

        _mint(msg.sender, newPostId);
        _setTokenURI(newPostId, postURI);

        ProfileToken memory newProfileToken = ProfileToken(TokenType.POST, postURI);
        profileTokens[newPostId] = newProfileToken;
        allProfilePosts.push(newProfileToken);

        setApprovalForAll(tweetContractAddress, true);
        emit PostCreated(postURI, newPostId, block.timestamp);

        return newPostId;
    }

    function createDiscussion(string memory discussionURI) public returns (uint256) {
        _tokenIds.increment();
        uint256 newDiscussionId = _tokenIds.current();

        _mint(msg.sender, newDiscussionId);
        _setTokenURI(newDiscussionId, discussionURI);

        ProfileToken memory newProfileToken = ProfileToken(TokenType.DISCUSSION, discussionURI);
        profileTokens[newDiscussionId] = newProfileToken;
        allProfileDiscussions.push(newProfileToken);

        setApprovalForAll(discussionContractAddress, true);
        emit DiscussionCreated(discussionURI, newDiscussionId, block.timestamp);

        return newDiscussionId;
    }

    // function getAllPosts() external view returns (ProfileToken[] memory) {
    //     return allProfilePosts;
    // }

    // function getAllDiscussions() external view returns (ProfileToken[] memory) {
    //     return allProfileDiscussions;
    // }

    function getTokenType(uint256 tokenId) external view returns (TokenType) {
        // require(_exists(tokenId), "Token does not exist");
        return profileTokens[tokenId].tokenType;
    }

    function getTokenURIById(uint256 tokenId) public view returns (string memory) {
        // require(_exists(tokenId), "Token does not exist");
        return profileTokens[tokenId].uri;
    }
}


contract ProfileFactory {
    struct MyNFTProfile {
        address owner;
        address ProfileContract;
        string username;
        string profileUrl;
        uint256 time;
    }

    address[] following;
    address[] followers;
    address[] cards;

    mapping(address => MyNFTProfile) public profileByAddressOwner; 
    mapping(address => MyNFTProfile) public profileByAddressContract; 
    mapping(string => MyNFTProfile) private profileByUsername;
    mapping(string => MyNFTProfile) private profileByUrl;
    mapping(address => address[]) public followingProfiles; // Mapping from user address to the addresses of profiles they follow
    mapping(address => address[]) public followersProfiles; // Mapping from user address to the addresses of profiles they follow
    mapping(address => address[]) public businessCards; // Mapping from user address to the addresses of profiles they follow

    MyNFTProfile[] public allNFTProfiles;

    event ProfileFollowed(address indexed follower, address indexed profile);
    event cardShared(address indexed sender, address indexed profile);

    event NFTProfileDeployed(
        address indexed owner, 
        address indexed ProfileContract, 
        string username, 
        string profileUrl, 
        uint256 time
    );

    function deployNFTProfileContract(address _tweetContractAddress, address _discussionContractAddress, string memory _username, string memory _profileUrl) external returns (address) {
        MyProfile ProfileContract = new MyProfile(_tweetContractAddress, _discussionContractAddress, _username, _profileUrl);
        MyNFTProfile memory newProfile = MyNFTProfile(msg.sender, address(ProfileContract), _username, _profileUrl, block.timestamp);
        
        profileByAddressContract[address(ProfileContract)] = newProfile;
        profileByAddressOwner[address(msg.sender)] = newProfile;
        profileByUsername[_username]  = newProfile;
        allNFTProfiles.push(newProfile);

        emit NFTProfileDeployed(msg.sender, address(ProfileContract), _username, _profileUrl, block.timestamp);
        return address(ProfileContract);
    }

    function getprofileByAddressContract (address _contractAddress) external view returns (MyNFTProfile memory) {
        return profileByAddressContract[_contractAddress];
    }

    // function getprofileByUsername (string memory _username) external view returns (MyNFTProfile memory) {
    //     return profileByUsername[_username];
    // }

    function getAllDeployedNFTCollections() external view returns (MyNFTProfile[] memory) {
        return allNFTProfiles;
    }
    
    function getprofileByAddressOwner() external view returns (MyNFTProfile memory) {
        return profileByAddressOwner[msg.sender];
    }

    function followProfile(address profileContract) public {
        // Ensure the user is not following the profile already
        require(!isFollowingProfile(msg.sender, profileContract), "You are already following this profile");
        address profileOwner = profileByAddressContract[profileContract].owner;

        // Add the profile to the list of profiles the user follows
        followingProfiles[msg.sender].push(profileOwner);

        // Add the follower to the list of followers of the profile being followed
        followersProfiles[profileOwner].push(msg.sender);

        // Emit an event to log the profile follow
        emit ProfileFollowed(msg.sender, profileContract);
    }

    function isFollowingProfile(address follower, address profileContract) public view returns (bool) {
        // Check if the follower is already following the profile
        address[] memory followedProfiles = followingProfiles[follower];
        for (uint256 i = 0; i < followedProfiles.length; i++) {
            if (followedProfiles[i] == profileContract) {
                return true;
            }
        }
        return false;
    }

    function getAllfollowers(address profile) external view returns (address[] memory) {
        address[] storage follower = followersProfiles[profile];
        address[] memory followersInfo = new address[](follower.length);

        for (uint256 i = 0; i < follower.length; i++) {
            followersInfo[i] = follower[i];
        }

        return followersInfo;
    }

    function getAllfollowing(address profile) external view returns (address[] memory) {
        address[] storage follow = followingProfiles[profile];
        address[] memory followingInfo = new address[](follow.length);

        for (uint256 i = 0; i < follow.length; i++) {
            followingInfo[i] = follow[i];
        }

        return followingInfo;
    }

    function shareCard(address profileContract) public {
        // Ensure the user is not following the profile already
        // require(!isFollowingProfile(msg.sender, profileContract), "You are already sent your card to this profile");
        address profileOwner = profileByAddressContract[profileContract].owner;

        // Add the card to the list of businessCards of the user to be sent
        businessCards[profileOwner].push(msg.sender);

        // Emit an event to log the profile follow
        emit cardShared(msg.sender, profileContract);
    }

    function getMybusinessCard() external view returns (address[] memory) {
        return businessCards[msg.sender];
    }
}