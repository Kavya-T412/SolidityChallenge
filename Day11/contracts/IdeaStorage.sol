// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

error IDEASTORAGE_UNAUTHORIZEDACCESS();
error IDEASTORAGE_INVALIDINDEX();

contract IdeaStorage{

    address private owner;
    uint256 public totalIdea;

    struct Idea{
        string title;
        string description;
        uint256 timestamp;
        bool isPublic;
    }

    mapping(address => Idea[]) private userIdeas;

    event IdeaAdded(string indexed title, string description, address indexed userAddress);
    event IdeaDeleted(uint256 indexed _indexNo, address indexed userAddress);

    constructor(){
        owner = msg.sender;
    }

    modifier onlyOwner(){
        if(owner != msg.sender) revert IDEASTORAGE_UNAUTHORIZEDACCESS();
        _;
    }

    // Stores user's ideas
    function addIdea(string memory _title, string memory _description, bool _isPublic) public{
        Idea memory idea = Idea(_title, _description, block.timestamp, _isPublic);
        userIdeas[msg.sender].push(idea);
        totalIdea++;
        emit IdeaAdded(_title, _description, msg.sender);
    }

    // Retrives caller's ideas
    function getMyIdea() public view returns(Idea[] memory){
        return userIdeas[msg.sender];
    } 

    // Gets all public ideas
    function getUserPublicIdeas(address _userAddress) public view returns(Idea[] memory){
        Idea[] memory ideas = userIdeas[_userAddress];
        uint256 count; // stores the no.of.public ideas
        for(uint256 i =0; i<ideas.length; i++){
            if(ideas[i].isPublic){
                count ++;
            }
        }

        Idea[] memory result = new Idea[](count); // empty array with exactly the size of public ideas 
        uint256 index;
        for(uint256 i=0; i<ideas.length; i++){
            if(ideas[i].isPublic){
                result[index] = ideas[i];
                index ++;
            }
        }
        return result;
    }

    // Deletes idea of caller's index number
    function deleteIdea(uint256 _indexNo) public {
        Idea[] storage idea = userIdeas[msg.sender];
        if(_indexNo >= idea.length) revert IDEASTORAGE_INVALIDINDEX();
        for(uint256 i= _indexNo; i<idea.length-1; i++){
            idea[i] = idea[i+1];
        }
        idea.pop();
        emit IdeaDeleted(_indexNo, msg.sender);
    }

    //Gets contract deployer's address
    function getOwner() public view returns(address){
        return owner;
    }

    // Returns user's idea count
    function getMyIdeaCount() public view returns(uint256){
        return userIdeas[msg.sender].length;
    }

    // Allow owner to delete user idea
    function deleteUserIdea(address _userAddress, uint256 _indexNo) public onlyOwner{
        Idea[] storage idea = userIdeas[_userAddress];
        for(uint i=_indexNo; i<idea.length-1; i++){
            idea[i] = idea[i+1];
        }
        idea.pop();
    }

    // Allow owner to see the user's idea count
    function getUserIdeaCount(address _userAddress) public onlyOwner view returns(uint256){
        return userIdeas[_userAddress].length;
    }
}