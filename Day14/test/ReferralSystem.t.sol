// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../contracts/ReferralSystem.sol";

contract ReferralSystemTest is Test{
    ReferralSystem private referralSystem;
    address private user1 = address(1);
    address private user2 = address(2);
    address private user3 = address(3);

    function setUp() public{
        referralSystem = new ReferralSystem();
    }

    function testOwnerSetCorrectly() public view{
        assertEq(referralSystem.getOwner(), address(this));
    }

    function testRegisterUser() public{
        referralSystem.register("John","Doe","john@mail.com");
        ReferralSystem.User memory user = referralSystem.getMyData();
        assertEq(user.fname,"John");
        assertEq(user.lname,"Doe");
        assertEq(user.emailAddress,"john@mail.com");
        assertTrue(referralSystem.isRegistered(address(this)));
    }

    function testDuplicateUserReverts() public{
        referralSystem.register("John","Doe","john@mail.com");
        vm.expectRevert(EXISTSING_USER.selector);
        referralSystem.register("John","Doe","john@mail.com");
    }

    function testUpdateUserData() public{
        referralSystem.register("John","Doe","john@mail.com");
        referralSystem.updateMyData("Jane","Smith","jane@mail.com");
        ReferralSystem.User memory user = referralSystem.getMyData();
        assertEq(user.fname,"Jane");
        assertEq(user.lname,"Smith");
        assertEq(user.emailAddress,"jane@mail.com");
    }

    function testAddReferral() public{
        vm.prank(user1);
        referralSystem.referralAddressOptional(address(this));

        assertEq(referralSystem.getMyTotalReferrals(),1);

        address[] memory referrals = referralSystem.getMyReferrals();
        assertEq(referrals.length,1);
        assertEq(referrals[0],user1);
    }

    function testSelfReferralReverts() public{
        vm.prank(user1);
        vm.expectRevert(SELF_REFERRAL_FAILED.selector);
        referralSystem.referralAddressOptional(user1);
    }

    function testZeroAddressReferralReverts() public{
        vm.prank(user1);
        vm.expectRevert(INVALID_REFERRAL_ADDRESS.selector);
        referralSystem.referralAddressOptional(address(0));
    }

    function testAlreadyReferredReverts() public{
        vm.startPrank(user1);

        referralSystem.referralAddressOptional(address(this));

        vm.expectRevert(ALREADY_REFFERRED.selector);
        referralSystem.referralAddressOptional(user2);

        vm.stopPrank();
    }

    function testGetReferrer() public{
        vm.prank(user1);
        referralSystem.referralAddressOptional(user2);

        vm.prank(user1);
        assertEq(referralSystem.getReferrer(),user2);
    }

    function testGetMyReferrals() public{
        vm.prank(user1);
        referralSystem.referralAddressOptional(address(this));

        vm.prank(user2);
        referralSystem.referralAddressOptional(address(this));

        address[] memory referrals = referralSystem.getMyReferrals();

        assertEq(referrals.length,2);
        assertEq(referrals[0],user1);
        assertEq(referrals[1],user2);
    }

    function testGetMyTotalReferrals() public{
        vm.prank(user1);
        referralSystem.referralAddressOptional(address(this));

        vm.prank(user2);
        referralSystem.referralAddressOptional(address(this));

        assertEq(referralSystem.getMyTotalReferrals(),2);
    }

    function testOwnerCanGetUserReferrals() public{
        vm.prank(user1);
        referralSystem.referralAddressOptional(address(this));

        address[] memory referrals = referralSystem.getUserReferrals(address(this));

        assertEq(referrals.length,1);
        assertEq(referrals[0],user1);
    }

    function testNonOwnerCannotGetUserReferrals() public{
        vm.prank(user1);

        vm.expectRevert(UNAUTHORIZED_ACCESS.selector);
        referralSystem.getUserReferrals(user2);
    }

    function testOwnerCanGetUserData() public{
        vm.prank(user1);
        referralSystem.register("John","Doe","john@mail.com");

        ReferralSystem.User memory user = referralSystem.getUserData(user1);

        assertEq(user.fname,"John");
        assertEq(user.lname,"Doe");
    }

    function testNonOwnerCannotGetUserData() public{
        vm.prank(user1);

        vm.expectRevert(UNAUTHORIZED_ACCESS.selector);
        referralSystem.getUserData(user2);
    }

    function testFundUser() public{
        vm.deal(address(this),10 ether);

        uint256 balanceBefore = user1.balance;

        referralSystem.fundUser{value:1 ether}(user1);

        uint256 balanceAfter = user1.balance;

        assertEq(balanceAfter,balanceBefore + 1 ether);
    }

    function testFundUserWithZeroEthReverts() public{
        vm.expectRevert(INVALID_ETH_AMOUNT.selector);
        referralSystem.fundUser{value:0}(user1);
    }

    function testNonOwnerCannotFundUser() public{
        vm.deal(user1,1 ether);

        vm.prank(user1);

        vm.expectRevert(UNAUTHORIZED_ACCESS.selector);
        referralSystem.fundUser{value:1 ether}(user2);
    }

    function testReceiveETH() public{
        vm.deal(user1,1 ether);

        vm.prank(user1);
        (bool success,) = address(referralSystem).call{value:1 ether}("");

        assertTrue(success);
    }

    function testFallbackETH() public{
        vm.deal(user1,1 ether);

        vm.prank(user1);
        (bool success,) = address(referralSystem).call{value:1 ether}(abi.encodeWithSignature("unknownFunction()"));

        assertTrue(success);
    }

    function testReferralCount() public{
        vm.prank(user1);
        referralSystem.referralAddressOptional(address(this));

        vm.prank(user2);
        referralSystem.referralAddressOptional(address(this));

        (,uint256 totalReferrals) = referralSystem.getAllReferralStatus();

        assertEq(totalReferrals,2);
    }
}