//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
//prevents re-entrancy attacks
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract TutorialGround is ReentrancyGuard, AccessControl {
    using SafeMath for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tutorialIds; //total number of Discussions ever created
    Counters.Counter private _tutorialLiked; //total number of likes of a Discussion
    Counters.Counter private _tutorialUnliked; //total number of dislikes of a Discussion
    Counters.Counter private _tutorialResources; //total number of Answers of a Discussion

    address public admin;

    mapping(uint256 => Counters.Counter) private numberOfResourcesPerTutorial;

    struct Tutorial {
        uint256 tutorialId;
        uint256 tutorialTokenId;
        address profileContract;
        address creator;
        uint256 like;
        uint256 dislike;
        uint256 resources;
        uint256 time;
    }

    struct Resources {
        address profileContract;
        uint256 tutorialID;
        uint256 resourceID;
        uint256 time;
    }

    //a way to access values of the Discussion and Answer struct above by passing an integer of the discussionID
    mapping(uint256 => Tutorial) public idTutorial;
    mapping(uint256 => Resources) public idResource;
    mapping(uint256 => Resources) public TutorialResource;
    mapping(uint256 => Resources[]) public ResourcesCreatedOnTutorial;
    mapping(address => mapping(uint256 => bool)) public likedBy;
    mapping(address => mapping(uint256 => bool)) public unLikedBy;

    //log message (when Discussion is sold)
    event TutorialCreated(
        uint256 indexed tutorialId,
        address indexed profileContract,
        uint256 indexed tutorialTokenId,
        address creator,
        uint256 like,
        uint256 dislike,
        uint256 answer,
        uint256 time
    );

    event ResourceUploaded(
        address profileContract,
        uint256 tutorialID,
        uint256 resourceID,
        uint256 time
    );

    event TutorialLiked(
        uint256 indexed tutorialID,
        address indexed liker,
        uint256 timestamp,
        bool like
    );

    constructor() {
        admin = msg.sender;
    }

    /// @notice function to create market Discussion
    function createTutorial(
        address profileContract,
        uint256 tokenId
    ) public nonReentrant {
        _tutorialIds.increment(); //add 1 to the total number of Discussions ever created
        uint256 tutorialId = _tutorialIds.current();

        idTutorial[tutorialId] = Tutorial(
            tutorialId,
            tokenId,
            profileContract,
            msg.sender,
            0,
            0,
            0,
            block.timestamp
        );

        //transfer ownership of the nft to the contract itself
        IERC721(profileContract).transferFrom(
            msg.sender,
            address(this),
            tokenId
        );

        //log this transaction
        emit TutorialCreated(
            tutorialId,
            profileContract,
            tokenId,
            msg.sender,
            0,
            0,
            0,
            block.timestamp
        );
    }


    //     }

    //     return AnswersInfo;
    // }

    /// @notice fetch list of NFTS owned/bought by this user
    function fetchMyTutorialCreated()
        public
        view
        returns (Tutorial[] memory)
    {
        //get total number of Discussions ever created
        uint256 totalTutorialCount = _tutorialIds.current();

        uint256 TutorialCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < totalTutorialCount; i++) {
            //get only the Discussions that this user has bought/is the owner
            if (idTutorial[i + 1].creator == msg.sender) {
                TutorialCount += 1; //total length
            }
        }

        Tutorial[] memory Tutorials = new Tutorial[](TutorialCount);
        for (uint256 i = 0; i < totalTutorialCount; i++) {
            if (idTutorial[i + 1].creator == msg.sender) {
                uint256 currentId = idTutorial[i + 1].tutorialId;
                Tutorial storage currentTutorial = idTutorial[currentId];
                Tutorials[currentIndex] = currentTutorial;
                currentIndex += 1;
            }
        }
        return Tutorials;
    }

    /// @notice Fetch list of NFTs owned/bought by this user
    function fetchAllTutorialCreated()
        public
        view
        returns (Tutorial[] memory)
    {
        // Get total number of Discussions ever created
        uint256 totalTutorialCount = _tutorialIds.current();

        // Initialize array to store all Discussions
        Tutorial[] memory allTutorials = new Tutorial[](
            totalTutorialCount
        );

        // Iterate through all Discussions and copy them to the array
        for (uint256 i = 1; i <= totalTutorialCount; i++) {
            uint256 tutorialId = idTutorial[i].tutorialId;
            Tutorial storage currentTutorial = idTutorial[tutorialId];
            allTutorials[i - 1] = currentTutorial;
        }

        return allTutorials;
    }

    
    function getADiscussion(uint256 tutorialId) public view returns (Tutorial memory) {
        // require(_exists(tokenId), "Token does not exist");
        return idTutorial[tutorialId];
    }

    function likeDiscussion(uint256 tutorialId) public nonReentrant {
        // Ensure the Discussion exists
        require(
            tutorialId > 0 && tutorialId <= _tutorialIds.current(),
            "Invalid Discussion ID"
        );

        // Ensure the user has not already liked the Discussion
        require(
            !likedBy[msg.sender][tutorialId],
            "You have already liked this Discussion"
        );

        // If the user has previously unliked the Discussion, decrement the dislike count and increment the like count
        if (unLikedBy[msg.sender][tutorialId]) {
            idTutorial[tutorialId].dislike--;
            idTutorial[tutorialId].like++;
            unLikedBy[msg.sender][tutorialId] = false;
        } else {
            // Increment the like count for the Discussion
            idTutorial[tutorialId].like++;
        }

        // Mark the Discussion as liked by the user
        likedBy[msg.sender][tutorialId] = true;

        // Emit an event to log the like
        emit TutorialLiked(tutorialId, msg.sender, block.timestamp, true);
    }

    function unLikeDiscussion(uint256 tutorialId) public nonReentrant {
        // Ensure the Discussion exists
        require(
            tutorialId > 0 && tutorialId <= _tutorialIds.current(),
            "Invalid Discussion ID"
        );

        // Ensure the user has not already liked the Discussion
        require(
            !unLikedBy[msg.sender][tutorialId],
            "You have already unliked this Discussion"
        );

        if (likedBy[msg.sender][tutorialId]) {
            // Increment the like count for the Discussion
            idTutorial[tutorialId].like--;
            idTutorial[tutorialId].dislike++;
            // Mark the Discussion as liked by the user
            likedBy[msg.sender][tutorialId] = false;
        } else {
            idTutorial[tutorialId].dislike++;
        }

        unLikedBy[msg.sender][tutorialId] = true;

        // Emit an event to log the like
        emit TutorialLiked(tutorialId, msg.sender, block.timestamp, false);
    }

    // Modifier to restrict access to the owner of the contract
    modifier onlyOwner() {
        require(msg.sender == admin, "Only the owner can call this function");
        _; // This indicates that the function's code should be inserted here
    }
}
