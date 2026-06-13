// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// Utils contract to provide common functionalities and modifiers for the student record system

import {AdminManager} from "./AdminManager.sol";

error STUDENTRECORDSYSTEM_UNAUTHORIZED_ACCESS(address owner_Or_StaffAddress);
error STUDENTRECORDSYSTEM_STAFFADDRESS_CANT_BE_ZERO_ADDRESS();
error STUDENTRECORDSYSTEM_INACTIVE_CONTRACT();
error STUDENTRECORDSYSTEM_ETH_TRANSFER_FAILED();
error STUDENTRECORDSYSTEM_INVALID_ADDRESS();

contract Utils is AdminManager {
    enum ContractState{NotActive, Active}
    address internal owner;
    ContractState private state;

    event ManagementRenounced(address indexed oldManagerAddress, address indexed ownerAddress);
    event ContractActivated(address indexed ownerAddress);
    event ContractDeactivated(address indexed ownerAddress);
    event EthWithdrawn(address indexed ownerAddress, address indexed receiverAddress, uint256 indexed ethAmount);
    event OwnershipTransferred(address indexed ownerAddress, address indexed newOwnerAddress);
    event OwnershipRenounced(address indexed ownerAddress, address indexed zeroAddress);
    event EthReceived(address indexed senderAddress, uint256 indexed ethAmount);

    // Restricts access to only contract owner
    modifier onlyOwner(){
        if(msg.sender != owner) revert STUDENTRECORDSYSTEM_UNAUTHORIZED_ACCESS(owner);
        _;
    }

    // Restricts access to only active contract
    modifier isActive(){
        if(state == ContractState.NotActive) revert STUDENTRECORDSYSTEM_INACTIVE_CONTRACT();
        _;
    }

    // Restricts access to only academic managers
    modifier isAcademicManager(){
        if(msg.sender != academicRecordManager) revert STUDENTRECORDSYSTEM_UNAUTHORIZED_ACCESS(academicRecordManager);
        _;
    }

    // Restricts access to only staff members
    modifier isRegistrar(){
        if(msg.sender != studentRegistrar) revert STUDENTRECORDSYSTEM_UNAUTHORIZED_ACCESS(studentRegistrar);
        _;
    }

    // Restricts access to only grades managers
    modifier isGradesManager(){
        if(msg.sender != gradesManager) revert STUDENTRECORDSYSTEM_UNAUTHORIZED_ACCESS(gradesManager);
        _;
    }

    // Returns contract's state
    function isContractActive() public view returns (string memory){
        if(state == ContractState.NotActive) return "NotActive";
        if(state == ContractState.Active) return "Active";
        return "Unknown state";
    }

    // Returns admin manager's address
    function getOwner() public view returns (address){
        return owner;
    }

    // Assigns admin manager
    function assignAdminManager(address _staffAddress) external onlyOwner isActive{
        if(_staffAddress == address(0)) revert STUDENTRECORDSYSTEM_STAFFADDRESS_CANT_BE_ZERO_ADDRESS();
        adminManager = _staffAddress;
        emit AdminManagerAssigned(_staffAddress);
    }

    // Allows owner and staff members to renounce their management roles
    function renounceManagement() external onlyOwner isActive{
        if(msg.sender == adminManager){
            adminManager = owner;
        }
        if(msg.sender == academicRecordManager){
            academicRecordManager = owner;
        }
        if(msg.sender == gradesManager){
            gradesManager = owner;
        }

        emit ManagementRenounced(msg.sender, owner);
    }

    // Only owner can activate contract
    function activateContract() external onlyOwner{
        state = ContractState.Active;
        emit ContractActivated(msg.sender);
    }

    // Only owner can deactivate contract
    function deactivateContract() external onlyOwner{
        state = ContractState.NotActive;
        emit ContractDeactivated(msg.sender);
    }

    // Only owner can withdraw ETH from the contract
    function withdrawETH(address _receiverAddress, uint256 _amount) external onlyOwner{
        if(_receiverAddress == address(0)) revert STUDENTRECORDSYSTEM_INVALID_ADDRESS();
        (bool success, ) = payable(_receiverAddress).call{value: _amount}("");
        if(!success) revert STUDENTRECORDSYSTEM_ETH_TRANSFER_FAILED();
        emit EthWithdrawn(owner, _receiverAddress, _amount);
    }

    // Only owner can transfer ownership
    function transferOwnership(address _newOwnerAddress) external onlyOwner{
        if(_newOwnerAddress == address(0)) revert STUDENTRECORDSYSTEM_INVALID_ADDRESS();
        emit OwnershipTransferred(owner, _newOwnerAddress);
        owner = _newOwnerAddress;
    }

    // Only owner can renounce ownership
    function renounceOwnership() external onlyOwner{
        emit OwnershipRenounced(owner, address(0));
        owner = address(0);
    }

    // Handles ETH transfers with no call data
    receive() external payable{
        emit EthReceived(msg.sender, msg.value);
    }

    // Handles ETH transfers with call data that doesn't match any function signature
    fallback() external payable{
        emit EthReceived(msg.sender, msg.value);
    }
}
