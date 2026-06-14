// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

library AuctionStruct {

    // Struct to represent an item available for auction
    struct ItemData {
        uint256 itemId;
        uint256 quantity;
        uint256 startingPrice;
        uint256 listedAt;
        uint256 endsAt;
        address owner;
        string title;
        string description;
        string itemType;
    }
}