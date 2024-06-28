//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
//prevents re-entrancy attacks
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract DiscussionGround is ReentrancyGuard, AccessControl {
    using SafeMath for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _discussionIds; //total number of Discussions ever created
    Counters.Counter private _Discussionsliked; //total number of likes of a Discussion
    Counters.Counter private _Discussionsunliked; //total number of dislikes of a Discussion
    Counters.Counter private _DiscussionsAnswers; //total number of Answers of a Discussion

    address public admin;

    mapping(uint256 => Counters.Counter) private numberOfAnswersPerDiscussion;

    struct Discussion {
        uint256 discussionId;
        uint256 discussionTokenId;
        address profileContract;
        address creator;
        uint256 like;
        uint256 dislike;
        uint256 answer;
        uint256 time;
    }

    struct Answer {
        address profileContract;
        address answeror;
        uint256 discussionID;
        uint256 answerID;
        string answerUrl;
        uint256 like;
        uint256 dislike;
        uint256 time;
    }

    //a way to access values of the Discussion and Answer struct above by passing an integer of the discussionID
    mapping(uint256 => Discussion) public idDiscussion;
    mapping(uint256 => Answer) public idAnswer;
    mapping(uint256 => Answer) public DiscussionAnswer;
    mapping(uint256 => Answer[]) public AnswersMadeToDiscussion;
    mapping(address => mapping(uint256 => bool)) public likedBy;
    mapping(address => mapping(uint256 => bool)) public unLikedBy;
    mapping(address => mapping(uint256 => bool)) public answerLikedBy;
    mapping(address => mapping(uint256 => bool)) public answerUnLikedBy;

    //log message (when Discussion is sold)
    event DiscussionCreated(
        uint256 indexed discussionID,
        address indexed profileContract,
        uint256 indexed discussionTokenId,
        address creator,
        uint256 like,
        uint256 dislike,
        uint256 answer,
        uint256 time
    );

    event AnswerMade(
        address profileContract,
        address answeror,
        uint256 discussionID,
        uint256 answerID,
        string answerUrl,
        uint256 time
    );

    event DiscussionLiked(
        uint256 indexed discussionID,
        address indexed liker,
        uint256 timestamp,
        bool like
    );

    event AnswerLiked(
        uint256 indexed answerID,
        address indexed liker,
        uint256 timestamp,
        bool like
    );

    constructor() {
        admin = msg.sender;
    }

    /// @notice function to create market Discussion
    function createDiscussion(
        address profileContract,
        uint256 tokenId
    ) public nonReentrant {
        _discussionIds.increment(); //add 1 to the total number of Discussions ever created
        uint256 discussionId = _discussionIds.current();

        idDiscussion[discussionId] = Discussion(
            discussionId,
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
        emit DiscussionCreated(
            discussionId,
            profileContract,
            tokenId,
            msg.sender,
            0,
            0,
            0,
            block.timestamp
        );
    }

    function AnswerDiscussion(
        uint256 discussionID,
        string memory answerUrl
    ) public nonReentrant {
        // Extract necessary details
        address profileContract = idDiscussion[discussionID].profileContract;

        address answeror = msg.sender;

        // Increment Answer counter for this Discussion
        numberOfAnswersPerDiscussion[discussionID].increment();

        idDiscussion[discussionID].answer++;

        // Store the Answer
        uint256 answerID = numberOfAnswersPerDiscussion[discussionID].current();
        AnswersMadeToDiscussion[discussionID].push(
            Answer({
                profileContract: profileContract,
                answeror: answeror,
                discussionID: discussionID,
                answerID: answerID,
                answerUrl: answerUrl,
                like: 0,
                dislike: 0,
                time: block.timestamp
            })
        );

        emit AnswerMade(
            profileContract,
            answeror,
            discussionID,
            answerID,
            answerUrl,
            block.timestamp
        );
    }


    function getAllAnswersMadeToDiscussion(uint256 discussionID)
        external
        view
        returns (Answer[] memory)
    {
        Answer[] storage Answers = AnswersMadeToDiscussion[discussionID];
        Answer[] memory AnswersInfo = new Answer[](Answers.length);

        for (uint256 i = 0; i < Answers.length; i++) {
            AnswersInfo[i] = Answer({
                profileContract: Answers[i].profileContract,
                answeror: Answers[i].answeror,
                discussionID: Answers[i].discussionID,
                answerID: Answers[i].answerID,
                answerUrl: Answers[i].answerUrl,
                like: Answers[i].like,
                dislike: Answers[i].dislike,
                time: Answers[i].time
            });
        }

        return AnswersInfo;
    }

    // function getAllAnswersMadeToDiscussion(
    //     uint256 discussionID,
    //     uint256 page,
    //     uint256 limit
    // ) external view returns (Answer[] memory) {
    //     Answer[] storage Answers = AnswersMadeToDiscussion[discussionID];
    //     uint256 start = page * limit;
    //     uint256 end = start + limit;

    //     // Ensure the start index is within the bounds of the array
    //     require(start < Answers.length, "Page out of range");

    //     // Adjust the end index if it exceeds the array length
    //     if (end > Answers.length) {
    //         end = Answers.length;
    //     }

    //     // Create a new array to hold the paginated results
    //     Answer[] memory AnswersInfo = new Answer[](end - start);

    //     for (uint256 i = start; i < end; i++) {
    //         AnswersInfo[i - start] = Answer({
    //             profileContract: Answers[i].profileContract,
    //             answeror: Answers[i].answeror,
    //             discussionID: Answers[i].discussionID,
    //             answerID: Answers[i].answerID,
    //             answerUrl: Answers[i].answerUrl,
    //             time: Answers[i].time
    //         });
    //     }

    //     return AnswersInfo;
    // }

    /// @notice fetch list of NFTS owned/bought by this user
    function fetchMyDiscussionsCreated()
        public
        view
        returns (Discussion[] memory)
    {
        //get total number of Discussions ever created
        uint256 totalDiscussionCount = _discussionIds.current();

        uint256 DiscussionCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < totalDiscussionCount; i++) {
            //get only the Discussions that this user has bought/is the owner
            if (idDiscussion[i + 1].creator == msg.sender) {
                DiscussionCount += 1; //total length
            }
        }

        Discussion[] memory Discussions = new Discussion[](DiscussionCount);
        for (uint256 i = 0; i < totalDiscussionCount; i++) {
            if (idDiscussion[i + 1].creator == msg.sender) {
                uint256 currentId = idDiscussion[i + 1].discussionId;
                Discussion storage currentDiscussion = idDiscussion[currentId];
                Discussions[currentIndex] = currentDiscussion;
                currentIndex += 1;
            }
        }
        return Discussions;
    }

    /// @notice Fetch list of NFTs owned/bought by this user
    function fetchAllDiscussionsCreated()
        public
        view
        returns (Discussion[] memory)
    {
        // Get total number of Discussions ever created
        uint256 totalDiscussionCount = _discussionIds.current();

        // Initialize array to store all Discussions
        Discussion[] memory allDiscussions = new Discussion[](
            totalDiscussionCount
        );

        // Iterate through all Discussions and copy them to the array
        for (uint256 i = 1; i <= totalDiscussionCount; i++) {
            uint256 discussionId = idDiscussion[i].discussionId;
            Discussion storage currentDiscussion = idDiscussion[discussionId];
            allDiscussions[i - 1] = currentDiscussion;
        }

        return allDiscussions;
    }

    function fetchDiscussionsCreated()
        public
        view
        returns (Discussion[] memory)
    {
        uint256 DiscussionCount = _discussionIds.current();
        uint256 currentIndex = 0;

        Discussion[] memory Discussions = new Discussion[](DiscussionCount);

        //loop through all items ever created
        for (uint256 i = 0; i < DiscussionCount; i++) {
            uint256 currentId = idDiscussion[i + 1].discussionId;
            Discussion storage currentDiscussion = idDiscussion[currentId];
            Discussions[currentIndex] = currentDiscussion;
            currentIndex += 1;
        }
        return Discussions;
    }

    function getADiscussion(uint256 discussionId) public view returns (Discussion memory) {
        // require(_exists(tokenId), "Token does not exist");
        return idDiscussion[discussionId];
    }

    function likeDiscussion(uint256 discussionID) public nonReentrant {
        // Ensure the Discussion exists
        require(
            discussionID > 0 && discussionID <= _discussionIds.current(),
            "Invalid Discussion ID"
        );

        // Ensure the user has not already liked the Discussion
        require(
            !likedBy[msg.sender][discussionID],
            "You have already liked this Discussion"
        );

        // If the user has previously unliked the Discussion, decrement the dislike count and increment the like count
        if (unLikedBy[msg.sender][discussionID]) {
            idDiscussion[discussionID].dislike--;
            idDiscussion[discussionID].like++;
            unLikedBy[msg.sender][discussionID] = false;
        } else {
            // Increment the like count for the Discussion
            idDiscussion[discussionID].like++;
        }

        // Mark the Discussion as liked by the user
        likedBy[msg.sender][discussionID] = true;

        // Emit an event to log the like
        emit DiscussionLiked(discussionID, msg.sender, block.timestamp, true);
    }

    function unLikeDiscussion(uint256 discussionID) public nonReentrant {
        // Ensure the Discussion exists
        require(
            discussionID > 0 && discussionID <= _discussionIds.current(),
            "Invalid Discussion ID"
        );

        // Ensure the user has not already liked the Discussion
        require(
            !unLikedBy[msg.sender][discussionID],
            "You have already unliked this Discussion"
        );

        if (likedBy[msg.sender][discussionID]) {
            // Increment the like count for the Discussion
            idDiscussion[discussionID].like--;
            idDiscussion[discussionID].dislike++;
            // Mark the Discussion as liked by the user
            likedBy[msg.sender][discussionID] = false;
        } else {
            idDiscussion[discussionID].dislike++;
        }

        unLikedBy[msg.sender][discussionID] = true;

        // Emit an event to log the like
        emit DiscussionLiked(discussionID, msg.sender, block.timestamp, false);
    }


    function likeAnswer(uint256 answerID, uint256 discussionId) public nonReentrant {
        // Ensure the Discussion exists
        require(
            answerID > 0 && answerID <= AnswersMadeToDiscussion[discussionId].length,
            "Invalid answer ID"
        );

        // Ensure the user has not already liked the answer
        require(
            !answerLikedBy[msg.sender][answerID],
            "You have already liked this answer"
        );

        // If the user has previously unliked the answer, decrement the dislike count and increment the like count
        if (answerUnLikedBy[msg.sender][answerID]) {
            AnswersMadeToDiscussion[discussionId][answerID - 1].dislike--;
            AnswersMadeToDiscussion[discussionId][answerID - 1].like++;
            answerUnLikedBy[msg.sender][answerID] = false;
        } else {
            // Increment the like count for the answer
            AnswersMadeToDiscussion[discussionId][answerID - 1].like++;
        }

        // Mark the answer as liked by the user
        answerLikedBy[msg.sender][answerID] = true;

        // Emit an event to log the like
        emit AnswerLiked(answerID, msg.sender, block.timestamp, true);
    }

    function unLikeAnswer(uint256 answerID, uint256 discussionId) public nonReentrant {
        // Ensure the answer exists
        require(
            answerID > 0 && answerID <= AnswersMadeToDiscussion[discussionId].length,
            "Invalid answer ID"
        );

        // Ensure the user has not already unliked the answer
        require(
            !answerUnLikedBy[msg.sender][answerID],
            "You have already unliked this answer"
        );

        if (answerLikedBy[msg.sender][answerID]) {
            // Decrement the like count for the answer
            AnswersMadeToDiscussion[discussionId][answerID - 1].like--;
            AnswersMadeToDiscussion[discussionId][answerID - 1].dislike++;
            // Mark the answer as not liked by the user
            answerLikedBy[msg.sender][answerID] = false;
        } else {
            // Increment the dislike count for the answer
            AnswersMadeToDiscussion[discussionId][answerID - 1].dislike++;
        }

        // Mark the answer as unliked by the user
        answerUnLikedBy[msg.sender][answerID] = true;

        // Emit an event to log the unlike action
        emit AnswerLiked(answerID, msg.sender, block.timestamp, false);
    }

    // Modifier to restrict access to the owner of the contract
    modifier onlyOwner() {
        require(msg.sender == admin, "Only the owner can call this function");
        _; // This indicates that the function's code should be inserted here
    }
}
