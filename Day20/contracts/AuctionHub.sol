// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Utils} from "./Utils.sol";
import {AuctionLib} from "./AuctionLib.sol";
import {AuctionTypes} from "./AuctionTypes.sol";
import {AuctionStruct} from "./AuctionStruct.sol";

error SIMPLEAUCTION_QUANTITY_CANT_BE_ZERO();
error SIMPLEAUCTION_STARTING_PRICE_CANT_BE_ZERO();
error SIMPLEAUCTION_ACCESS_DENIED();
error SIMPLEAUCTION_INVALID_ITEMID();

contract AuctionHub is Utils {

    using AuctionStruct for AuctionStruct.ItemData; // Used ItemData from AuctionStruct
    using AuctionLib for AuctionLib.AuctionData; // Used AuctionData from AuctionLib

    uint256 public itemCount; // Records item count
    AuctionLib.AuctionData internal seller; // Seller is assigned to AuctionData struct in AuctionLib 

    event ItemRegistered(address indexed sellerAddress, uint256 itemId, string itemTitle, uint256 indexed itemQuantity);
    event ItemUpdated(address indexed sellerAddress, uint256 itemId, string newTitle, uint256 indexed newQuantity);
    event AuctionActivated(uint256 indexed itemId, address indexed sellerAddress);
    event AuctionDeactivated(uint256 indexed itemId, address indexed sellerAddress);
    event AuctionEnded(uint256 indexed itemId, address indexed sellerAddress, address indexed winner, uint256 winningBid);
    event AuctionCancelled(uint256 indexed itemId, address indexed sellerAddress);
    event ItemDeleted(uint256 indexed itemId, address indexed sellerAddress);

    // Restricts access to item owners 
    modifier itemOwner(uint256 _itemId){
        if(msg.sender != seller.itemsById[_itemId].owner) revert SIMPLEAUCTION_ACCESS_DENIED();
        _;
    }

    // Allows sellers to register items for auction
    function register(string memory _title, string memory _description, string memory _itemType, uint256 _quantity, uint256 _startingPrice, uint256 _endsAt) internal isActive {
        if(_quantity <= 0) revert SIMPLEAUCTION_QUANTITY_CANT_BE_ZERO();
        if(_startingPrice <= 0) revert SIMPLEAUCTION_STARTING_PRICE_CANT_BE_ZERO();
        itemCount++;
        uint256 _itemId = itemCount;

        AuctionStruct.ItemData memory itemData = AuctionStruct.ItemData ({
            itemId: _itemId,
            quantity: _quantity,
            startingPrice: _startingPrice,
            listedAt: block.timestamp,
            endsAt: _endsAt,
            owner: msg.sender,
            title: _title,
            description: _description,
            itemType: _itemType
        });
        seller.sellerInfo[msg.sender].push(itemData);
        seller.itemsById[_itemId] = itemData;

        emit ItemRegistered(msg.sender, _itemId, _title, _quantity);
    }

    // Allows sellers to update items
    function update(uint256 _itemId, string memory _newTitle, string memory _newDescription, string memory _newItemType, uint256 _newQuantity, uint256 _newStartingPrice, uint256 _newEndsAt) internal isActive itemOwner(_itemId){
        if(_newQuantity <= 0) revert SIMPLEAUCTION_QUANTITY_CANT_BE_ZERO();
        if(_newStartingPrice <= 0) revert SIMPLEAUCTION_STARTING_PRICE_CANT_BE_ZERO();
        AuctionStruct.ItemData storage newItemData = seller.itemsById[_itemId];

        newItemData.title = _newTitle;
        newItemData.description = _newDescription;
        newItemData.itemType = _newItemType;
        newItemData.quantity = _newQuantity;
        newItemData.startingPrice = _newStartingPrice;
        newItemData.endsAt = _newEndsAt;
        newItemData.listedAt = block.timestamp;

        seller.itemsById[_itemId] = newItemData;

        emit ItemUpdated(msg.sender, _itemId, _newTitle, _newQuantity);
    }

    //Deletes seller's item
    function deleteItem(uint256 _itemId) internal isActive itemOwner(_itemId) {
        delete seller.itemsById[_itemId];
        AuctionStruct.ItemData[] storage itemData = seller.sellerInfo[msg.sender];
        for(uint256 i=0; i<itemData.length; i++){
            if(itemData[i].itemId == _itemId){
                itemData[i] = itemData[itemData.length-1];
                itemData.pop();

                unchecked {
                    itemCount--;
                }
            }
        }

        emit ItemDeleted(_itemId, msg.sender);
        return;
    }

    // Activates the aution
    function activate(uint256 _itemId) internal isActive itemOwner(_itemId){
        seller.itemState[_itemId] = AuctionTypes.AuctionState.Active;
        emit AuctionActivated(_itemId, msg.sender);
    }

    // Deactivate the auction
    function deactivate(uint256 _itemId) internal isActive itemOwner(_itemId){
        seller.itemState[_itemId] = AuctionTypes.AuctionState.NotActive;
        emit AuctionDeactivated(_itemId, msg.sender);
    }

    // Ends auction
    function end(uint256 _itemId) internal isActive itemOwner(_itemId){
        seller.itemState[_itemId] = AuctionTypes.AuctionState.Ended;
        emit AuctionEnded(_itemId, msg.sender, seller.highestBidder[_itemId], seller.highestBid[_itemId]);
    }

    // Cancels Auction
    function cancelAuction(uint256 _itemId) internal isActive itemOwner(_itemId){
        seller.itemState[_itemId] = AuctionTypes.AuctionState.Cancelled;
        emit AuctionCancelled(_itemId, msg.sender);
    }
    
}