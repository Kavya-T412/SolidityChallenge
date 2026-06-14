// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Utils} from "./Utils.sol";
import {AuctionHub} from "./AuctionHub.sol";
import {BidZone} from "./BidZone.sol";
import {AuctionLib} from "./AuctionLib.sol";
import {AuctionTypes} from "./AuctionTypes.sol";
import {AuctionStruct} from "./AuctionStruct.sol";

error SIMPLEAUCTION_ETH_AMOUNT_TOO_LOW();
error SIMPLEAUCTION_NONEXISTING_ITEMID();
error SIMPLEAUCTION_ACUTION_NOT_ACTIVE();
error SIMPLEAUCTION_AUCTION_ENDED();
error SIMPLEAUCTION_AUCTION_CANCELLED();

contract SimpleAuction is Utils, AuctionHub, BidZone {

    using AuctionLib for AuctionLib.AuctionData;
    using AuctionStruct for AuctionStruct.ItemData;

    // Sets contract deployer as auctioneer
    constructor() {
        auctioneer = msg.sender;
    }

    // Allows sellers to register new items for auction
    function registerItem(string memory _title, string memory _description, string memory _itemType, uint256 _quantity, uint256 _startingPrice, uint256 _endsAt) external isActive {
        register(_title, _description, _itemType, _quantity, _startingPrice, _endsAt);
    }

    // Allows sellers to update items
    function updateItem(uint256 _itemId, string memory _newTitle, string memory _newDescription, string memory _newItemType, uint256 _newQuantity, uint256 _newStartingPrice, uint256 _newEndsAt) external isActive {
        update(_itemId, _newTitle, _newDescription, _newItemType, _newQuantity, _newStartingPrice, _newEndsAt);
    }

    // Deletes seller's item and all related data
    function deleteMyItem(uint256 _itemId) external isActive {
        deleteItem(_itemId);
    }

    // Activates auction
    function activateAuction(uint256 _itemId) external isActive{
        activate(_itemId);
    }

    // Deactivates auction
    function deactivateAuction(uint256 _itemId) external isActive{
        deactivate(_itemId);
    }

    // Ends Auction
    function endAuction(uint256 _itemId) external isActive {
        end(_itemId);
    }

    // Allows bidders to bid on items
    function bidItem(uint256 _itemId) external payable isActive {
        bid(_itemId);
        emit SuccessfulBid(msg.sender, _itemId, msg.value);
    }

    // Allows bidders to withdraw ETH
    function withdrawMyETH(uint256 _ethAmount) external isActive{
        withdraw(_ethAmount);
    }

    // Allows winning bidder to claim the item
    function claimMyItem(uint256 _itemId) external isActive {
        claim(_itemId);
    }

    // Returns auction data
    function getAuction(uint256 _itemId) external view returns(AuctionStruct.ItemData memory) {
        return seller.itemsById[_itemId];
    }

    // Returns auction state as string
    function getAuctionStateAsString(uint256 _itemId) external view returns(string memory) {
        AuctionTypes.AuctionState state = seller.itemState[_itemId];
        return AuctionTypes.auctionStateToString(state);
    }

    // Returns highest bidder's address
    function getWinner(uint256 _itemId) external view returns(address){
        return seller.highestBidder[_itemId];
    }

    // Returns Item's total bids
    function getItemBidCount(uint256 _itemId) external view returns(uint256) {
        return seller.bidRecord[_itemId];
    }
}