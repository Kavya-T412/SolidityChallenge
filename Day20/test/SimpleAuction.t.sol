// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import { Test } from "forge-std/Test.sol";

import { AuctionStruct } from "../contracts/AuctionStruct.sol";
import { SimpleAuction } from "../contracts/SimpleAuction.sol";

contract SimpleAuctionTest is Test {
    SimpleAuction private auction;

    address private constant SELLER = address(0x1001);
    address private constant BIDDER = address(0x2001);

    function setUp() public {
        auction = new SimpleAuction();
        auction.activateContract();
    }

    function testConstructorSetsAuctioneerToDeployer() public {
        SimpleAuction fresh = new SimpleAuction();

        assertEq(fresh.getAuctioneer(), address(this));
    }

    function testOnlyAuctioneerCanActivateContract() public {
        SimpleAuction fresh = new SimpleAuction();

        vm.prank(BIDDER);
        vm.expectRevert(abi.encodeWithSignature("SIMPLEAUCTION_UNAUTHORIZED_ACCESS(address)", address(this)));
        fresh.activateContract();
    }

    function testRegisterItemStoresAuctionData() public {
        uint256 endsAt = block.timestamp + 1 days;

        vm.prank(SELLER);
        auction.registerItem("Rare NFT", "One of one auction item", "NFT", 1, 1 ether, endsAt);

        assertEq(auction.getAuctioneer(), address(this));
        assertEq(auction.itemCount(), 1);

        AuctionStruct.ItemData memory itemData = auction.getAuction(1);
        assertEq(itemData.itemId, 1);
        assertEq(itemData.quantity, 1);
        assertEq(itemData.startingPrice, 1 ether);
        assertEq(itemData.endsAt, endsAt);
        assertEq(itemData.owner, SELLER);
        assertEq(itemData.title, "Rare NFT");
        assertEq(itemData.description, "One of one auction item");
        assertEq(itemData.itemType, "NFT");
        assertEq(auction.getAuctionStateAsString(1), "Not Active");
    }

    function testBidItemTracksWinnerAndBidCount() public {
        uint256 endsAt = block.timestamp + 1 days;
        uint256 bidAmount = 2 ether;

        vm.prank(SELLER);
        auction.registerItem("Rare NFT", "One of one auction item", "NFT", 1, 1 ether, endsAt);

        vm.prank(SELLER);
        auction.activateAuction(1);

        vm.deal(BIDDER, 10 ether);
        vm.prank(BIDDER);
        auction.bidItem{value: bidAmount}(1);

        assertEq(auction.getWinner(1), BIDDER);
        assertEq(auction.getItemBidCount(1), 1);
        assertEq(auction.getContractBalance(), bidAmount);
    }

    function testWinningBidderCanClaimAfterAuctionEnds() public {
        uint256 endsAt = block.timestamp + 1 days;

        vm.prank(SELLER);
        auction.registerItem("Rare NFT", "One of one auction item", "NFT", 1, 1 ether, endsAt);

        vm.prank(SELLER);
        auction.activateAuction(1);

        vm.deal(BIDDER, 10 ether);
        vm.prank(BIDDER);
        auction.bidItem{value: 2 ether}(1);

        vm.warp(endsAt + 1);
        vm.prank(BIDDER);
        auction.claimMyItem(1);

        AuctionStruct.ItemData memory itemData = auction.getAuction(1);
        assertEq(itemData.owner, BIDDER);
    }
}