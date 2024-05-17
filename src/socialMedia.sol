//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
//prevents re-entrancy attacks
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract AlphaConnect is ReentrancyGuard, AccessControl {
    using SafeMath for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _PostIds; //total number of Posts ever created
    Counters.Counter private _Postsliked; //total number of likes of a post
    Counters.Counter private _Postsunliked; //total number of dislikes of a post
    Counters.Counter private _PostsComments; //total number of comments of a post
    Counters.Counter private _NewsIds; //total number of Posts ever created
    Counters.Counter private _NewsUnPublished; //total number of Posts ever created

    address public immutable admin;

    mapping(uint256 => Counters.Counter) private numberOfCommentsPerPost;

    struct Post {
        uint256 PostId;
        uint256 postTokenId;
        address profileContract;
        address creator;
        uint256 like;
        uint256 dislike;
        uint256 comment;
        uint256 time;
    }

    struct News {
        uint256 NewsId;
        string newsUrl;
        address creator;
        uint256 time;
        bool publish;
    }

    struct Comment {
        address profileContract;
        address commentor;
        uint256 PostID;
        uint256 commentID;
        string commentUrl;
        uint256 time;
    }

    struct Likes {
        uint256 postID;
        address liker;
        uint256 timestamp;
        bool like;
    }

    //a way to access values of the post and comment struct above by passing an integer of the PostID
    mapping(uint256 => Post) public idPost;
    mapping(uint256 => Comment) public idComment;
    mapping(uint256 => Comment) public PostComment;
    mapping(uint256 => Comment[]) public commentsMadeToPost;
    mapping(uint256 => Likes[]) likeOfPost;
    mapping(address => mapping(uint256 => bool)) public likedBy;
    mapping(address => mapping(uint256 => bool)) public unLikedBy;
    mapping(uint256 => News) public idNews;

    //log message (when Post is sold)
    event PostCreated(
        uint256 indexed PostId,
        address indexed profileContract,
        uint256 indexed postTokenId,
        address creator,
        uint256 like,
        uint256 dislike,
        uint256 comment,
        uint256 time
    );

    //log message (when Post is sold)
    event NewsCreated(
        uint256 indexed NewsId,
        string newsUrl,
        address creator,
        uint256 time
    );
    event NewsUpdated(uint256 indexed NewsId, string updatedUrl);
    event NewsDeleted(uint256 indexed NewsId);

    event commentMade(
        address profileContract,
        address commentor,
        uint256 PostID,
        uint256 commentID,
        string commentUrl,
        uint256 time
    );

    event PostLiked(
        uint256 indexed postID,
        address indexed liker,
        uint256 timestamp,
        bool like
    );

    constructor() {
        admin = msg.sender;
    }

    /// @notice function to create market Post
    function createPost(
        address profileContract,
        uint256 tokenId
    ) public nonReentrant {
        _PostIds.increment(); //add 1 to the total number of Posts ever created
        uint256 PostId = _PostIds.current();

        idPost[PostId] = Post(
            PostId,
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
        emit PostCreated(
            PostId,
            profileContract,
            tokenId,
            msg.sender,
            0,
            0,
            0,
            block.timestamp
        );
    }

    function commentPost(
        uint256 postID,
        string memory commentUrl
    ) public nonReentrant {
        // Extract necessary details
        address profileContract = idPost[postID].profileContract;
        address commentor = msg.sender;

        // Increment comment counter for this post
        numberOfCommentsPerPost[postID].increment();

        idPost[postID].comment++;

        // Store the comment
        uint256 commentID = numberOfCommentsPerPost[postID].current();
        commentsMadeToPost[postID].push(
            Comment({
                profileContract: profileContract,
                commentor: commentor,
                PostID: postID,
                commentID: commentID,
                commentUrl: commentUrl,
                time: block.timestamp
            })
        );

        emit commentMade(
            profileContract,
            commentor,
            postID,
            commentID,
            commentUrl,
            block.timestamp
        );
    }

    function getAllCommentsMadeToPost(
        uint256 postID
    ) external view returns (Comment[] memory) {
        Comment[] storage comments = commentsMadeToPost[postID];
        Comment[] memory commentsInfo = new Comment[](comments.length);

        for (uint256 i = 0; i < comments.length; i++) {
            commentsInfo[i] = Comment({
                profileContract: comments[i].profileContract,
                commentor: comments[i].commentor,
                PostID: comments[i].PostID,
                commentID: comments[i].commentID,
                commentUrl: comments[i].commentUrl,
                time: comments[i].time
            });
        }

        return commentsInfo;
    }

    /// @notice fetch list of NFTS owned/bought by this user
    function fetchMyPostsCreated() public view returns (Post[] memory) {
        //get total number of Posts ever created
        uint256 totalPostCount = _PostIds.current();

        uint256 PostCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < totalPostCount; i++) {
            //get only the Posts that this user has bought/is the owner
            if (idPost[i + 1].creator == msg.sender) {
                PostCount += 1; //total length
            }
        }

        Post[] memory Posts = new Post[](PostCount);
        for (uint256 i = 0; i < totalPostCount; i++) {
            if (idPost[i + 1].creator == msg.sender) {
                uint256 currentId = idPost[i + 1].PostId;
                Post storage currentPost = idPost[currentId];
                Posts[currentIndex] = currentPost;
                currentIndex += 1;
            }
        }
        return Posts;
    }

    /// @notice Fetch list of NFTs owned/bought by this user
    function fetchAllPostsCreated() public view returns (Post[] memory) {
        // Get total number of Posts ever created
        uint256 totalPostCount = _PostIds.current();

        // Initialize array to store all posts
        Post[] memory allPosts = new Post[](totalPostCount);

        // Iterate through all posts and copy them to the array
        for (uint256 i = 1; i <= totalPostCount; i++) {
            uint256 postId = idPost[i].PostId;
            Post storage currentPost = idPost[postId];
            allPosts[i - 1] = currentPost;
        }

        return allPosts;
    }

    function fetchPostsCreated() public view returns (Post[] memory) {
        uint256 postCount = _PostIds.current();
        uint256 currentIndex = 0;

        Post[] memory post = new Post[](postCount);

        //loop through all items ever created
        for (uint256 i = 0; i < postCount; i++) {
            uint256 currentId = idPost[i + 1].PostId;
            Post storage currentpost = idPost[currentId];
            post[currentIndex] = currentpost;
            currentIndex += 1;
        }
        return post;
    }

    function likePost(uint256 postID) public nonReentrant {
        // Ensure the post exists
        require(postID > 0 && postID <= _PostIds.current(), "Invalid post ID");

        // Ensure the user has not already liked the post
        require(
            !likedBy[msg.sender][postID],
            "You have already liked this post"
        );

        // If the user has previously unliked the post, decrement the dislike count and increment the like count
        if (unLikedBy[msg.sender][postID]) {
            idPost[postID].dislike--;
            idPost[postID].like++;
            unLikedBy[msg.sender][postID] = false;
        } else {
            // Increment the like count for the post
            idPost[postID].like++;
        }

        // Mark the post as liked by the user
        likedBy[msg.sender][postID] = true;

        // Emit an event to log the like
        emit PostLiked(postID, msg.sender, block.timestamp, true);
    }

    function unLikePost(uint256 postID) public nonReentrant {
        // Ensure the post exists
        require(postID > 0 && postID <= _PostIds.current(), "Invalid post ID");

        // Ensure the user has not already liked the post
        require(
            !unLikedBy[msg.sender][postID],
            "You have already unliked this post"
        );

        if (likedBy[msg.sender][postID]) {
            // Increment the like count for the post
            idPost[postID].like--;
            idPost[postID].dislike++;
            // Mark the post as liked by the user
            likedBy[msg.sender][postID] = false;
        } else {
            idPost[postID].dislike++;
        }

        unLikedBy[msg.sender][postID] = true;

        // Emit an event to log the like
        emit PostLiked(postID, msg.sender, block.timestamp, false);
    }

    function createNews(string memory newsUrl) public onlyOwner nonReentrant {
        _NewsIds.increment(); //add 1 to the total number of Posts ever created

        uint256 NewsId = _NewsIds.current();

        idNews[NewsId] = News(
            NewsId,
            newsUrl,
            msg.sender,
            block.timestamp,
            true
        );

        emit NewsCreated(NewsId, newsUrl, msg.sender, block.timestamp);
    }

    // Define a function to update news
    function updateNews(
        uint256 newsId,
        string memory updatedUrl
    ) public onlyOwner {
        idNews[newsId].newsUrl = updatedUrl;
        emit NewsUpdated(newsId, updatedUrl);
    }

    // Define a function to delete news
    function deleteNews(uint256 newsId) public onlyOwner {
        require(
            msg.sender == idNews[newsId].creator,
            "Only the author can delete the news"
        );
        _NewsUnPublished.increment(); //add 1 to the total number of Posts ever created
        idNews[newsId].publish = false;
        emit NewsDeleted(newsId);
    }

    // Define a function to get news details by ID
    function getNews(
        uint256 newsId
    ) public view returns (uint256, string memory, address, uint256) {
        require(
            newsId <= _NewsIds.current(),
            "News with given ID does not exist"
        );
        News memory news = idNews[newsId];
        return (news.NewsId, news.newsUrl, news.creator, news.time);
    }

    // @notice total number of items unsold on our platform
    function getAllPublishedNews() public view returns (News[] memory) {
        uint256 newsCount = _NewsIds.current(); // Total number of items ever created
        uint256 publishedCount = _NewsIds.current() - _NewsUnPublished.current();
        uint256 currentIndex = 0;

        News[] memory news = new News[](publishedCount);

        // Loop through all items ever created
        for (uint256 i = 0; i < newsCount; i++) {
            // Get only published news
            if (idNews[i + 1].publish == true) {
                // Yes, this news is available
                uint256 currentId = idNews[i + 1].NewsId;
                News storage currentItem = idNews[currentId];
                news[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return news; // Return array of all published news
    }

    function fetchAllNewsCreated() public view returns (News[] memory) {
        // Get total number of Posts ever created
        uint256 totalNewsCount = _NewsIds.current();

        // Initialize array to store all posts
        News[] memory allNews = new News[](totalNewsCount);

        // Iterate through all posts and copy them to the array
        for (uint256 i = 1; i <= totalNewsCount; i++) {
            uint256 newsId = idNews[i].NewsId;
            News storage currentNews = idNews[newsId];
            allNews[i - 1] = currentNews;
        }

        return allNews;
    }

    // Modifier to restrict access to the owner of the contract
    modifier onlyOwner() {
        require(msg.sender == admin, "Only the owner can call this function");
        _; // This indicates that the function's code should be inserted here
    }
}
