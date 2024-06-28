// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract MyProfile is ERC721URIStorage {
    // Payable fallback function
    fallback() external payable {}

    // Payable receive function (Solidity version >= 0.6.0)
    receive() external payable {}
    
    using Counters for Counters.Counter;
    Counters.Counter private _postIds;

    string public username;
    string public profileUrl;
    address public tweetContractAddress;
    address public discussionContractAddress;


    constructor(address _tweetContractAddress, address _discussionContractAddress, string memory _username, string memory _profileUrl) ERC721("eGa", "eGa") {
        tweetContractAddress = _tweetContractAddress;
        discussionContractAddress = _discussionContractAddress;
        username = _username;
        profileUrl = _profileUrl;
    }

}