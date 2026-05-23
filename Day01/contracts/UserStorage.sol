// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract UserStorage{
  address owner; //stores contract deployer's address
  
  //struct to hold user details (name and age)
  struct UserData {
    string name;
    uint256 age;
  }

  mapping(address => UserData) private userDetails; //links user address to their details (struct-UserData)

  constructor() {
    owner = msg.sender;
  }

  modifier onlyOwner(){
    require(msg.sender == owner, "Unauthorized Access");
    _;
  }
  //stores user details in the mapping using their address as the key
  function store(string memory _name, uint256 _age) public {
    userDetails[msg.sender] = UserData(_name, _age);
  }
  //retrieves user details from the mapping using their address as the key
  function getDetails(address user) public view returns(string memory, uint256){
    UserData memory data = userDetails[user];
    return (data.name,data.age);
  }
  //updates user details in the mapping using their address as the key
  function updateDetails(string memory _name, uint256 _age) public{
    UserData memory updateData = UserData(_name, _age);
    userDetails[msg.sender] = updateData;
  }
  //deletes user details from the mapping using their address as the key
  function deleteDetails() public {
    delete userDetails[msg.sender];
  }

}