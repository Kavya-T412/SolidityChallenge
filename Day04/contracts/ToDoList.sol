// SPDX-License-Identifier: MIT

error EMPTYTASK(); // Declaring custom error for empty task title

pragma solidity ^0.8.18;

contract ToDoList {

    address private owner; // Store the contract owner's address
    
    struct Task {
        string title;
        bool completed;
        uint256 timestamp;
    }
    mapping(address => Task[]) private userTasks; // Mapping to store tasks for each user

    constructor(){
        owner = msg.sender;
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "Unauthorised Access");
        _;
    }

    // Allow users to add a task to their to-do list
    function addTask(string memory _title) public{
        if(bytes(_title).length == 0) revert EMPTYTASK();
        userTasks[msg.sender].push(Task(_title, false, block.timestamp));
    }

    // Allow users to view their tasks
    function getMyTask() public view returns(Task[] memory){
        return userTasks[msg.sender];
    }

    // Allow users to mark a task as completed
    function markAsDone(uint256 _indexNo) public{
        userTasks[msg.sender][_indexNo].completed = true;
    }

    // Allow users to update the title of a task
    function updateTask(uint256 _indexNo, string memory _newTitle) public {
        userTasks[msg.sender][_indexNo] = Task(_newTitle, false, block.timestamp);
    }

    // Allow users to delete a task from their to-do list
    function deleteTask(uint256 _indexNo) public{
        delete userTasks[msg.sender][_indexNo];
    }

    // Allow users to delete all tasks from their to-do list
    function deleteAllTasks() public{
        delete userTasks[msg.sender];
    }

    // Allow users to view a specific task by its index
    function getTaskAtIndex(uint256 _indexNo) public view returns(Task memory){
        return userTasks[msg.sender][_indexNo];
    }

    // Allow users to view the total number of tasks in their to-do list
    function getTaskCount() public view returns (uint256 taskCount){
        return userTasks[msg.sender].length;
    }

    // Allow owner to view all tasks of all users
    function getAllTasks(address _user) public view onlyOwner returns(Task[] memory){
        return userTasks[_user];
    }


}