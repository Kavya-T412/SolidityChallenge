// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

error SIMPLEBANK_UNAUTHORIZED_ACCESS();
error SIMPLEBANK_ETHAMOUNTISTOOLOW();
error SIMPLEBANK_INSUFFICIENTBALANCE();

contract SimpleBank{

    address private owner;
    mapping(address => uint256) private userBalance; // mapping to store user balances

    event ethDeposited(address indexed depositor, uint256 amount); // event for logging deposits
    event ethWithdrawn(address indexed withdrawer, uint256 amount); // event for logging withdrawals

    constructor(){
        owner = msg.sender;
    }

    modifier onlyOwner(){
        if (owner != msg.sender){
            revert SIMPLEBANK_UNAUTHORIZED_ACCESS();
        }
        _;
    }

    // Allows users to deposit ETH
    function depositETH() public payable{
        if(msg.value <= 0) revert SIMPLEBANK_ETHAMOUNTISTOOLOW(); // Check for non-zero deposit
        userBalance[msg.sender] += msg.value; // Update user balance
        emit ethDeposited(msg.sender, msg.value); // Emit event for deposit
    }

    // Allows users to withdraw ETH
    function withdrawETH(uint256 _ethAmount) public{
        if(userBalance[msg.sender] < _ethAmount) revert SIMPLEBANK_INSUFFICIENTBALANCE(); // Check for sufficient balance
        userBalance[msg.sender] -= _ethAmount; // Update user balance
        (bool success, ) = payable(msg.sender).call{value: _ethAmount}(""); // Transfer ETH to user
        require(success, "Transfer failed");
        emit ethWithdrawn(msg.sender, _ethAmount);
    }

    // Allows users to check their own balance
    function getMyBalance() public view returns (uint256){
        return userBalance[msg.sender];
    }

    // Allows the owner to check the total balance of the bank
    function getBankBalance() public view onlyOwner returns (uint256){
        return address(this).balance;
    }

    // Allows the owner to check the balance of any user
    function getUserBalance(address _userAddress) public view onlyOwner returns(uint256){
        return userBalance[_userAddress];
    }
    
    // Allows the owner to transfer ownership of the bank
    function transferOwnership(address _newOwner) public onlyOwner{
        owner = _newOwner;
    }

    // Allows anyone to check the current owner of the bank
    function getOwner() public view returns (address){
        return owner;
    }


}