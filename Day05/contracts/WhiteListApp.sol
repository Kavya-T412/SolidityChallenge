// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

error WHITELIST_EXISTING_USER();
error WHITELIST_UNAUTHORIZED_ACCESS();

contract WhiteListApp{

    address private owner;
    uint256 public addressCount;

    mapping(address => bool) private whitelist; // Mapping to store whitelisted addresses
    address[] private userAddress; // Array to store whitelisted addresses 

    constructor(){
        owner = msg.sender;
    }

    modifier onlyOwner(){
        if(msg.sender != owner){
            revert WHITELIST_UNAUTHORIZED_ACCESS(); 
        }
        _;
    }
    
    // Allow users to join the whitelist
    function joinWhitelist() public {
        if(whitelist[msg.sender] == true) revert WHITELIST_EXISTING_USER();
        whitelist[msg.sender] = true;
        addressCount++;
        userAddress.push(msg.sender);
    }

    // Check if the sender is whitelisted
    function checkIfWhitelisted() public view returns (bool){
        return whitelist[msg.sender];
    }

    // Check if a specific user is whitelisted
    function checkIfUserIsWhitelisted(address _userAddress) public view returns (bool) {
        return whitelist[_userAddress];
    }

    // Allow the owner to delete a whitelisted address
    function deleteAddress(address _userAddress) public onlyOwner {
        delete whitelist[_userAddress];
        unchecked {
            addressCount--;
        }
    }

    // Get the list of all whitelisted users
    function getAllWhitelistedUsers() public view returns (address[] memory) {
        return userAddress;
    }

    // Get the owner of the contract
    function getOwner() public view returns (address) {
        return owner;
    }

 
}