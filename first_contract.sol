pragma solidity ^0.4.18;
pragma experimental ABIEncoderV2;

contract first_contract {
    
    struct User {
        bytes32 name;
        bool signedup;
        uint id;
        uint[] posts_made;
        int[] comments_made;
    }
    
    mapping (address => User) public userMap;
    address[] public userAddresses;
    mapping (bytes32 => bool) public takenUsernames;

    function signup(bytes32 _name) public{  
        if (userMap[msg.sender].signedup != true) {
            userMap[msg.sender].name = _name; 
            userMap[msg.sender].signedup = true;
            userAddresses.push(msg.sender);
            takenUsernames[_name] = true;
        }
    }
    
        function checkIfUser(bytes32 _name) view public returns (int) {
        if (userMap[msg.sender].signedup == true) {
            return 1;
        } else if (takenUsernames[_name] == true) {
            return 2;
        } else {
            return 0;
        }
    }
    
    function getUser(address _address) constant public returns (bytes32, uint[], int[]){
        User storage user = userMap[_address];
        return(user.name, user.posts_made, user.comments_made);
    }
    
    function getAllUsers() external view returns (address[]) {
      return userAddresses;
    }

    function login() view public returns (bytes32)  {  
        if (userMap[msg.sender].signedup == true) {
            return userMap[msg.sender].name;
        } else {
            return '';
        }
    }
    
    struct Comment {
        bytes32 commentstring;
        int votes;
        address auth_address;
        uint loggedin;
        bytes32 time;
        uint parentPostID;
        int commentID;
    }
    
    int num_usermade_comments;
    int num_anon_comments;
    mapping (int => Comment) comments_by_ids;
    
    struct Post {
        Comment[] post_comments;
    }
    
    bytes32[] public postarr;
    int[] public votearr;  //to avoid returning temp fn created arrays through posts when getting votes
    //we want to return all posts within same fn bc want to store them in local array to sort them
    bytes32[] public titlearr;
    bytes32[] public timearr;
    address[] public addressposts;
    bytes32[] public authorarr;  //avoids looping through addressposts
    uint[] public loggedin;
    
    mapping (uint => Post) posts;  //cannot do Post[] posts if have Comment[] post_comments as property of Post

    //storage defines contract state. memory is temp storage that's gone when fn exits
    //changing a var copied into a 'memory' var will not change the original var, as copy doesn't ref original
    //storage doesn't create a copy, but references the original
       
    event updatePage();
    
    function addPost(uint _postnum, bytes32 _title, bytes32 _poststring, bytes32 _time, uint _loggedin) public {
        postarr.push(_poststring);
        Post storage post = posts[_postnum]; //allocate memory for new Post struc
        timearr.push(_time);
        titlearr.push(_title);
        votearr.push(0);
        if(_loggedin == 1){
            userMap[msg.sender].posts_made.push(addressposts.length); //push postid to user array. postids start at 0
            addressposts.push(msg.sender);
            authorarr.push(userMap[msg.sender].name);
            loggedin.push(1);
        } else {
            addressposts.push(address(0));
            authorarr.push("");
            loggedin.push(0);
        }
    }
    
    function votePostUp(uint _postnum) public{
        votearr[_postnum]++;
        emit updatePage();
    }
    
    function votePostDown(uint _postnum) public{
        votearr[_postnum]--;
        emit updatePage();
    }
    
    function getPosts() view public returns (int[], bytes32[], bytes32[], bytes32[], address[], bytes32[], uint[]) {
        return (votearr, postarr, titlearr, timearr, addressposts, authorarr, loggedin);
    }

    function countPosts() view public returns (uint) {
        return postarr.length;
    }
    
    function addComment(bytes32 _commentstring, bytes32 _time, uint _loggedin, uint _postnum) public {
        //cannot store storage within Post Struct's post_comments array, so use memory
        Comment memory comment; //delete temp struc after adding copy of it to post's post_comments
        comment.commentstring = _commentstring;
        comment.time = _time;
        comment.parentPostID = _postnum;
        if(_loggedin == 1){
            comment.auth_address = msg.sender;
            comment.loggedin = 1;
            comment.commentID = num_usermade_comments;
            userMap[msg.sender].comments_made.push(num_usermade_comments); //push commentid to user array
            posts[_postnum].post_comments.push(comment);
            comments_by_ids[num_usermade_comments] = comment;
            num_usermade_comments++;  //comment ids start at 0
        } else {
            comment.loggedin = 0;
            num_anon_comments--;  //anon comment ids start at -1
            comment.commentID = num_anon_comments;
            posts[_postnum].post_comments.push(comment);
            comments_by_ids[num_anon_comments] = comment;
        }
        emit updatePage();
    }
    
    function voteCommentUp(uint _commentnum, uint _postnum) public{
        Comment storage comment = posts[_postnum].post_comments[_commentnum];
        //avoid anonymous upvoting affecting userpost by sending all anon post ids as -
        //hamfisted soln
        Comment storage comment2 = comments_by_ids[comment.commentID];
        comment.votes++;
        comment2.votes++;
        emit updatePage();
    }
    
    function voteCommentDown(uint _commentnum, uint _postnum) public{
        Comment storage comment = posts[_postnum].post_comments[_commentnum];
        Comment storage comment2 = comments_by_ids[comment.commentID];
        comment.votes--;
        comment2.votes--;
        emit updatePage();
    }
    
    function getCommentVotes(uint _commentnum, uint _postnum) view public returns (int) {
        Comment storage comment = posts[_postnum].post_comments[_commentnum];
        return (comment.votes);
    }
    
    function getCommentContent(uint _commentnum, uint _postnum) view public returns (bytes32) {
        Comment storage comment = posts[_postnum].post_comments[_commentnum];
        return (comment.commentstring);
    }
    
    function getCommentAuthor(uint _commentnum, uint _postnum) constant public returns (uint, bytes32, address) {
        Comment storage comment = posts[_postnum].post_comments[_commentnum];
        return (comment.loggedin, userMap[comment.auth_address].name, comment.auth_address);
    }
    
    function getCommentTime(uint _commentnum, uint _postnum) view public returns (bytes32) {
        Comment storage comment = posts[_postnum].post_comments[_commentnum];
        return (comment.time);
    }
    
    function getCommentByID(int _commentID) view public returns (int, bytes32, bytes32, bytes32, uint) {
        Comment storage comment = comments_by_ids[_commentID];
        return (comment.votes, comment.commentstring, userMap[comment.auth_address].name, comment.time, comment.parentPostID);
    }
    
    function countComments(uint _postnum) view public returns (uint) {
        return posts[_postnum].post_comments.length;
    }

}