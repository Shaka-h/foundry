// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract DiscussionContract is ERC721URIStorage {
    // Payable fallback function
    fallback() external payable {}

    // Payable receive function (Solidity version >= 0.6.0)
    receive() external payable {}

    using Counters for Counters.Counter;
    Counters.Counter private _discussionIds;

    address public profileContract;
    address public discussionContractAddress;

    string[] public allProfilePosts;
    string[] public allProfileDiscussions;
    mapping(uint256 => string) profileURIById;

    event discussionCreated(string profileURI, uint256 profileId, uint256 time);

    constructor(
        address _discussionContractAddress,
        address _profileContract
    ) ERC721("eGa", "eGa") {
        discussionContractAddress = _discussionContractAddress;
        profileContract = _profileContract;

    }

    function createDiscussion(string memory discussionURI)
        public
        returns (uint256)
    {
        _discussionIds.increment(); // Increment the profile ID counter
        uint256 newdiscussionId = _discussionIds.current(); // Get the new profile ID

        _mint(msg.sender, newdiscussionId); // Mint the profile to the caller
        _setTokenURI(newdiscussionId, discussionURI); // Set the profile URI

        allProfileDiscussions.push(discussionURI); // Add the new discussion ID to the array
        profileURIById[newdiscussionId] = discussionURI; // Store the profile URI in the mapping
        setApprovalForAll(discussionContractAddress, true); //grant transaction permission to marketplace
        emit discussionCreated(discussionURI, newdiscussionId, block.timestamp);

        return newdiscussionId; // Return the new profile ID
    }

    function getAlldiscussions() external view returns (string[] memory) {
        return allProfileDiscussions;
    }

    function getDiscussionsURIById(uint256 profileId)
        external
        view
        returns (string memory)
    {
        return profileURIById[profileId];
    }
}

