// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Utils} from "./Utils.sol";
import {AuctionHub} from "./AuctionHub.sol";
import {AuctionLib} from "./AuctionLib.sol";
import {AuctionTypes} from "./AuctionTypes.sol";
import {AuctionStruct} from "./AuctionStruct.sol";

error SIMPLEAUCTION_ETH_AMOUNT_IS_TOO_LOW();
error SIMPLEAUCTION_NONEXISTING_ITEMID();
error SIMPLEAUCTION_AUCTION_NOT_ACTIVE();
error SIMPLEAUCTION_AUCTION_ENDED();
error SIMPLEAUCTION_ETH_BALANCE_IS_TOO_LOW();
error SIMPLEAUCTION_AUCTION_CANCELLED();
error SIMPLEAUCTION_ETH_TRANSFER_FAILED();
error SIMPLEAUCTION_WITHDRAW_ONLY_WHEN_OUT_BIDDED();
error SIMPLEAUCTION_AUCTION_IS_STILL_ACTIVE();
error SIMPLEAUCTION_ACCESS_DENIED();

contract BidZone is Utils, AuctionHub {
    
    using AuctionLib for AuctionLib.AuctionData;
    using AuctionStruct for AuctionStruct.ItemData;
    uint256 public totalBid;

    event SuccessfulBid(address indexed bidderAddress, uint256 indexed itemId, uint256 ethAmount);
    event EthWithdrawn(address indexed bodderAddress, uint256 indexed ethAmount);
    event ItemClaimed(address indexed bidderAddress, uint256 itemId);

    // Allows bidders bid on items
    function bid(uint _itemId) internal isActive {
        AuctionStruct.ItemData memory itemData = seller.itemsById[_itemId];
        if(itemData.owner == address(0)) revert SIMPLEAUCTION_NONEXISTING_ITEMID();
        if(block.timestamp > itemData.endsAt) revert SIMPLEAUCTION_AUCTION_ENDED();
        if(msg.value <= 0) revert SIMPLEAUCTION_ETH_AMOUNT_IS_TOO_LOW();
        if(msg.value <= seller.highestBid[_itemId]) revert SIMPLEAUCTION_ETH_AMOUNT_IS_TOO_LOW();
        if(seller.itemState[_itemId] == AuctionTypes.AuctionState.NotActive) revert SIMPLEAUCTION_AUCTION_NOT_ACTIVE();
        if(seller.itemState[_itemId] == AuctionTypes.AuctionState.Cancelled) revert SIMPLEAUCTION_AUCTION_CANCELLED();
        if(seller.itemState[_itemId] == AuctionTypes.AuctionState.Ended) revert SIMPLEAUCTION_AUCTION_ENDED();

        seller.highestBidder[_itemId] = msg.sender; // Stores bidder as new highest bidder
        seller.bidderRecords[msg.sender] += msg.value; // Store ETH on bidder's address
        seller.highestBid[_itemId] = msg.value; // Stores ETH as new highest bid
        totalBid++;

        seller.bidRecord[_itemId] += 1; // Store bid count for itemId

        emit SuccessfulBid(msg.sender, _itemId, msg.value);
    }

    // Allows bidders to withdraw ETH
    function withdraw(uint256 _ethAmount) internal isActive {
        if(_ethAmount > seller.bidderRecords[msg.sender]) revert SIMPLEAUCTION_ETH_BALANCE_IS_TOO_LOW();
        if(_ethAmount == seller.bidderRecords[msg.sender]) revert SIMPLEAUCTION_WITHDRAW_ONLY_WHEN_OUT_BIDDED();

        (bool success, ) = payable(msg.sender).call{value: _ethAmount}("");
        if(!success) revert SIMPLEAUCTION_ETH_TRANSFER_FAILED();
        seller.bidderRecords[msg.sender] -= _ethAmount;

        emit EthWithdrawn(msg.sender, _ethAmount);
    }

    // Allows bidders to claim items
    function claim(uint256 _itemId) internal isActive {
        AuctionStruct.ItemData memory itemData = seller.itemsById[_itemId]; // Access item data using the item ID
        if(block.timestamp < itemData.endsAt) revert SIMPLEAUCTION_AUCTION_IS_STILL_ACTIVE();
        if(seller.itemState[_itemId] == AuctionTypes.AuctionState.Cancelled) revert SIMPLEAUCTION_AUCTION_CANCELLED();
        if(msg.sender != seller.highestBidder[_itemId]) revert SIMPLEAUCTION_ACCESS_DENIED();

        seller.itemsById[_itemId].owner = msg.sender; // Assigns highest bidder as item owner
        seller.bidderRecords[msg.sender] = 0; // Reset highest bidder's Eth after claim

        emit ItemClaimed(msg.sender, _itemId);
    }
}