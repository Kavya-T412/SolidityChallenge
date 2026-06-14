// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

library AuctionTypes {

    // Enum to represent the state of an auction
    enum AuctionState{NotActive, Active, Ended, Cancelled}

    // Convert AuctionState enum to string
    function auctionStateToString(AuctionState state) internal pure returns (string memory){
        
        if(state == AuctionState.NotActive) return "Not Active";
        if(state == AuctionState.Active) return "Active";
        if(state == AuctionState.Ended) return "Ended";
        if(state == AuctionState.Cancelled) return "Cancelled";
        
        return "Invalid Auction State";
    }
}