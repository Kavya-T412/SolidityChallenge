// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {AuctionTypes} from "./AuctionTypes.sol";

error SIMPLEAUCTION_INVALID_TIMESTAMP();
error SIMPLEAUCTION_UNAUTHORIZED_ACCESS(address auctioneer);
error SIMPLEAUCTION_INVALID_ADDRESS(address zeroAddress);
error SIMPLEAUCTION_CONTRACT_IS_NOT_ACTIVE();
error SIMPLEAUCTION_ETH_TRANSFER_FAILLED();

contract Utils {

    using AuctionTypes for AuctionTypes.AuctionState; // Used AuctionState from AuctionTypes

    enum ContractState {NotActive, Active} // Defines contract state (0 => NotActive, 1=> Active )

    address internal auctioneer;
    ContractState private state;
    AuctionTypes.AuctionState internal auctionState;

    event ContractActivated();
    event InActiveContract();
    event ContractOwnershipTransferrred(address indexed auctioneerAddress, address indexed newAuctioneerAddress);
    event EthSent(address indexed auctioneerAddress, address indexed receiverAddress, uint256 indexed ethAmount);
    event EthReceived(address indexed senderAddress, uint256 indexed ethAmount);

    // Restricts access to only contract deployer (auctioneer)
    modifier onlyAuctioneer() {
        if(msg.sender != auctioneer) revert SIMPLEAUCTION_UNAUTHORIZED_ACCESS(auctioneer);
        _;
    }

    // Restricts access when contract is not active
    modifier isActive() {
        if(state != ContractState.Active) revert SIMPLEAUCTION_CONTRACT_IS_NOT_ACTIVE();
        _;
    }

    // Returns contract's balance
    function getContractBalance() external view returns(uint256){
        return address(this).balance;
    }

    // Returns the address of the auctioneer (contract deployer)
    function getAuctioneer() external view returns(address){
        return auctioneer;
    }

    // Only contract depolyer can transfer the ownership
    function transferOwnership(address _newAuctioneerAddress) external onlyAuctioneer isActive {
        if(_newAuctioneerAddress == address(0)) revert SIMPLEAUCTION_INVALID_ADDRESS(_newAuctioneerAddress);
        emit ContractOwnershipTransferrred(auctioneer, _newAuctioneerAddress);
        auctioneer = _newAuctioneerAddress;
    }

    // Only auctioneer can activate the contract
    function activateContract() external onlyAuctioneer {
        state = ContractState.Active;
        emit ContractActivated();
    }

    // Only auctioneer can deactivate the contract
    function deactivateContract() external onlyAuctioneer {
        state = ContractState.NotActive;
        emit InActiveContract();
    }

    // Only autioneer can refund ETH received from bidder who didn't click on bid
    function withdrawETH(address _receiverAddress, uint256 _ethAmount) external onlyAuctioneer isActive {
        (bool success,) = payable(_receiverAddress).call{value: _ethAmount}("");
        if(!success) revert SIMPLEAUCTION_ETH_TRANSFER_FAILLED();
        emit EthSent(auctioneer, _receiverAddress, _ethAmount);
    }

    // Handles ETH deposit without calldata
    receive() external payable{
        emit EthReceived(msg.sender, msg.value);
    }

    // Handles ETH deposit with calldata
    fallback() external payable {
        emit EthReceived(msg.sender, msg.value);
    }
}