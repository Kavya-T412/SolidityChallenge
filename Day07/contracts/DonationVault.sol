// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

error DONATIONVAULT_INSUFFECIENTBALANCE(); // Reverted when the owner tries to withdraw but the contract balance is zero
error DONATIONVAULT_UNAUTHORIZED_ACCESS(); // Reverted when an unauthorized address tries to access owner-only functions
error DONATIONVAULT_ETHAMOUNTISTOOLOW(); // Reverted when the amount of ETH deposited is zero or negative

contract DonationVault{

    address private owner;
    mapping(address=>uint256) private userDonation; // Links user address to the total amount of ETH they have deposited

    event newDeposit(uint256 indexed _ethAmount, address _userAddress); // Reverted to indexed for better filtering in event logs
    event ownerWithdrewAll(uint256 indexed ethAmount, address ownerAddress); // Reverted to indexed for better filtering in event logs

    constructor(){
        owner = msg.sender;
    }

    modifier onlyOwner(){
        if(msg.sender != owner) revert DONATIONVAULT_UNAUTHORIZED_ACCESS();
        _;
    }

    // Accepts ETH deposit
    function depositETH() public payable {
        if(msg.value <=0 ) revert DONATIONVAULT_ETHAMOUNTISTOOLOW();
        userDonation[msg.sender] += msg.value;
        emit newDeposit(msg.value, msg.sender);
    }

    // Allows the owner to withdraw all the ETH from the contract
    function withdrawAll() public onlyOwner{
        uint256 balance = address(this).balance;
        if(balance == 0) revert DONATIONVAULT_INSUFFECIENTBALANCE();
        (bool success, ) = payable(owner).call{value:balance}("");
        require(success, "Withdraw Failed");
        emit ownerWithdrewAll(balance,owner);
    }

    // Returns the total amount of ETH deposited 
    function getTotalDeposit() public view onlyOwner returns(uint256){
        return userDonation[address(this)];
    }

    // Returns the total amount of ETH deposited by the caller
    function getMyDepositHistory() public view returns(uint256){
        return userDonation[msg.sender];
    }

    // Returns the address of the contract owner
    function getOwner() public view returns(address){
        return owner;
    }
    
    
    
}