// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {AuctionStruct} from "./AuctionStruct.sol";
import {AuctionTypes} from "./AuctionTypes.sol";

library AuctionLib {

    using AuctionStruct for AuctionStruct.ItemData; // Used ItemData from AuctionStruct
    using AuctionTypes for AuctionTypes.AuctionState; // Used AuctionState from AuctionTypes

    // Groups mapping for seller's data, bidder's data and item data
    struct AuctionData {
        
        // Maps seller's address => itemData
        mapping (address => AuctionStruct.ItemData[]) sellerInfo;
        
        // Maps item id => itemData
        mapping (uint256 => AuctionStruct.ItemData) itemsById;
        
        // Maps bidder's address => total amount they have bid across all auctions
        mapping (address => uint256) bidderRecords;

        // Maps item id => auction state
        mapping (uint256 => AuctionTypes.AuctionState) itemState;
        
        // Maps item id => highest bid amount
        mapping(uint256 => uint256) highestBid;
        
        // Maps item id => highest bidder's address
        mapping(uint256 => address) highestBidder;
        
        // Maps item id => bid count
        mapping(uint256 => uint256) bidRecord;
    }
}