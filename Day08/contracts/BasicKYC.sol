// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

error BASICKYC_EXISTINGUSER(); // Custom error for existing user registration
error BASICKYC_USERISVERIFIED(); // Custom error for marking an already verified user as verified again
error BASICKYC_USERISNOTVERIFIED(); // Custom error for removing verification from a user who is not verified
error BASICKYC_UNAUTHORIZEDACCESS(); // Custom error for unauthorized access to owner-only functions 

contract BasicKYC {
    address private owner;
    uint256 public totalUsers; // Records number of users

    struct User{
        string fname;
        string lname;
        address userAddress;
    }

    mapping(address => User) userDetails; // Links user address to their details 
    mapping(address => bool) userVerification; // Tracks whether a user's address has been verified or not

    event newUserRegistered(string indexed fname, address indexed userAddress); // Emits when a new user registers
    event newAddressVerified(address indexed userAddress); // Emits when a user's address is marked as verified
    event userDeleted(address indexed userAddress); // Emits when a user's data is deleted, either by the user or the owner

    constructor(){
        owner = msg.sender;
    }

    modifier onlyOwner(){
        if(msg.sender != owner) revert BASICKYC_UNAUTHORIZEDACCESS();
        _;
    }

    // Stores user details
    function register(string memory _fname, string memory _lname, address _userAddress) public{
        if(bytes(userDetails[msg.sender].fname).length != 0) revert BASICKYC_EXISTINGUSER();
        userDetails[msg.sender] = User(_fname, _lname, _userAddress);
        totalUsers++;
        emit newUserRegistered(_fname, _userAddress);
    }

    // Returns the caller's registered KYC details
    function getMyDetails() public view returns(string memory, string memory, address){
        User memory user = userDetails[msg.sender];
        return (user.fname, user.lname, user.userAddress);
    }

    // Allow owner to get any user's details using their address
    function getUserDetail(address _userAddress) public view onlyOwner returns(string memory, string memory){
        User memory user = userDetails[_userAddress];
        return (user.fname, user.lname);
    }

    // Marks a user's address as verified, only callable by the owner
    function markAsVerified(address _userAddress) public onlyOwner{
        if(userVerification[_userAddress] == true) revert BASICKYC_USERISVERIFIED();
        userVerification[_userAddress] = true;
        emit newAddressVerified(_userAddress);
    }

    // Checks if the caller's address is verified
    function checkIfVerified() public view returns(bool){
        return userVerification[msg.sender];
    }

    // Checks if a specific user's address is verified, only callable by the owner
    function checkIfUserIsVerified(address _userAddress) public view returns(bool){
        return userVerification[_userAddress];
    }

    // Allows the owner to remove verification from a user's address
    function removeUserVerification(address _userAddress) public onlyOwner{
        if (userVerification[_userAddress] == false) revert BASICKYC_USERISNOTVERIFIED();
        userVerification[_userAddress] = false;
    }

    // Allows the owner to delete a user's data from the contract
    function deleteUser(address _userAddress) public onlyOwner{
        delete userDetails[_userAddress];
        emit userDeleted(_userAddress);
    }

    // Allows a user to delete their own data from the contract
    function deleteMyData() public{
        delete userDetails[msg.sender];
        emit userDeleted(msg.sender);
    }

    // Returns the address of the contract owner
    function getOwner() public view returns (address){
        return owner;
    }
}