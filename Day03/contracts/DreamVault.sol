// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract DreamVault{

    address private owner; //stores the address of the contract deployer
    struct Dream{
        string title;
        string description;
        uint256 addAt;
    }
    mapping(address => Dream) private userDreams; //maps each user's address to their dream
    uint256 public dreamCount; //stores the total number of dreams
    address[] private dreamersAddresses; //stores the addresses of all users who have added a dream

    constructor(){
        owner = msg.sender;
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }
    
    // Stores user's dream and verifies if the user's dream is unique then increases dream count
    function storeDream(string memory _title, string memory _description) public{
        if(bytes(userDreams[msg.sender].title).length == 0){
            dreamersAddresses.push(msg.sender);
            dreamCount++;
        }
        userDreams[msg.sender] = Dream(_title, _description, block.timestamp);
    }
    
    // Retrieves the user's dream details
    function viewMyDream() public view returns(string memory, string memory, uint256){
        Dream memory dream = userDreams[msg.sender];
        return(dream.title, dream.description, dream.addAt);
    }
    
    // Updates the user's dream details
    function updateDream(string memory newDream, string memory newDescription) public{
        userDreams[msg.sender] = Dream(newDream, newDescription, block.timestamp);
    }
    
    // Deletes the user's dream and updates the dream count
    function deleteDream() public{
        delete userDreams[msg.sender];
        dreamCount--;
    }
    
    // Retrieves the dream details of a specific user by the owner
    function viewAllDreams(address _dreamer) public view onlyOwner returns(string memory, string memory, uint256){
        Dream memory dream = userDreams[_dreamer];
        return(dream.title, dream.description, dream.addAt);
    }

    // Retrieves the address of a specific user who has added a dream by the owner using the index of the dreamersAddresses array
    function getDremerAtIndex(uint256 index) public view onlyOwner returns(address){
        require(index < dreamersAddresses.length, "Index out of bounds");
        return dreamersAddresses[index];
    }
    
    // Retrieves the addresses of all users who have added a dream by the owner
    function getAllDreamers() public view onlyOwner returns(address[] memory){
        return dreamersAddresses;
    }


}