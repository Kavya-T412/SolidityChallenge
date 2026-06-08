// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../contracts/WalletGuard.sol";

contract WalletGuardTest is Test {
    WalletGuard private walletGuard;

    address private user1 = address(1);
    address private user2 = address(2);
    address private safeAddress = address(3);

    function setUp() public {
        walletGuard = new WalletGuard();
        walletGuard.activateContract();
    }

    function testOwnerSetCorrectly() public view {
        assertEq(walletGuard.getOwner(), address(this));
    }

    function testRegisterUser() public {
        vm.prank(user1);
        walletGuard.register("John", "Doe", user1);

        assertEq(walletGuard.addressCount(), 1);
    }

    function testDuplicateRegistrationReverts() public {
        vm.startPrank(user1);

        walletGuard.register("John", "Doe", user1);

        vm.expectRevert(WALLETGUARD_ALREADY_REGISTERED.selector);
        walletGuard.register("John", "Doe", user1);

        vm.stopPrank();
    }

    function testRegisterWithZeroAddressReverts() public {
        vm.prank(user1);

        vm.expectRevert(WALLETGUARD_INVALID_ADDRESS.selector);
        walletGuard.register("John", "Doe", address(0));
    }

    function testWhitelistAddress() public {
        vm.prank(user1);

        walletGuard.whitelistAddress(safeAddress);
        vm.prank(user1);
        address[] memory list = walletGuard.getMyWhitelistedAddress();

        assertEq(list.length, 1);
        assertEq(list[0], safeAddress);
        assertEq(walletGuard.safeAddressCount(), 1);
    }

    function testWhitelistZeroAddressReverts() public {
        vm.prank(user1);

        vm.expectRevert(WALLETGUARD_INVALID_ADDRESS.selector);
        walletGuard.whitelistAddress(address(0));
    }

    function testWhitelistOwnAddressReverts() public {
        vm.prank(user1);

        vm.expectRevert(WALLETGUARD_INVALID_ADDRESS.selector);
        walletGuard.whitelistAddress(user1);
    }

    function testDuplicateWhitelistReverts() public {
        vm.startPrank(user1);

        walletGuard.whitelistAddress(safeAddress);

        vm.expectRevert(WALLETGUARD_ALREADY_WHITELISTED.selector);
        walletGuard.whitelistAddress(safeAddress);

        vm.stopPrank();
    }

    function testGetWhitelistedAddress() public {
        vm.prank(user1);
        walletGuard.whitelistAddress(safeAddress);

        vm.prank(user1);
        address[] memory list = walletGuard.getMyWhitelistedAddress();

        assertEq(list.length, 1);
        assertEq(list[0], safeAddress);
    }

    function testUpdateWhitelistedAddress() public {
        vm.startPrank(user1);

        walletGuard.whitelistAddress(safeAddress);

        walletGuard.updateWhitelistedAddress(0, user2);

        address[] memory list = walletGuard.getMyWhitelistedAddress();

        assertEq(list[0], user2);

        vm.stopPrank();
    }

    function testUpdateInvalidIndexReverts() public {
        vm.prank(user1);

        vm.expectRevert(WALLETGUARD_INVALID_INDEX.selector);
        walletGuard.updateWhitelistedAddress(0, user2);
    }

    function testUpdateWithZeroAddressReverts() public {
        vm.startPrank(user1);

        walletGuard.whitelistAddress(safeAddress);

        vm.expectRevert(WALLETGUARD_INVALID_ADDRESS.selector);
        walletGuard.updateWhitelistedAddress(0, address(0));

        vm.stopPrank();
    }

    function testDeactivateContract() public {
        walletGuard.deactivateContract();

        vm.prank(user1);

        vm.expectRevert(WALLETGUARD_PAUSED_CONTRACT.selector);
        walletGuard.register("John", "Doe", user1);
    }

    function testOnlyOwnerCanActivate() public {
        vm.prank(user1);

        vm.expectRevert(WALLETGUARD_UNAUTHORIZED_ACCESS.selector);
        walletGuard.activateContract();
    }

    function testOnlyOwnerCanDeactivate() public {
        vm.prank(user1);

        vm.expectRevert(WALLETGUARD_UNAUTHORIZED_ACCESS.selector);
        walletGuard.deactivateContract();
    }

    function testOnlyOwnerCanSendETH() public {
        vm.deal(user1, 1 ether);

        vm.prank(user1);

        vm.expectRevert(WALLETGUARD_UNAUTHORIZED_ACCESS.selector);
        walletGuard.sendETHToWhitelisted{value: 1 ether}(safeAddress);
    }

    function testSendETHAccessDenied() public {
        vm.expectRevert(WALLETGUARD_ACCESS_DENIED.selector);

        walletGuard.sendETHToWhitelisted{value: 1 ether}(safeAddress);
    }

    function testReceiveETH() public {
        vm.deal(user1, 1 ether);

        vm.prank(user1);

        (bool success,) = address(walletGuard).call{value: 1 ether}("");

        assertTrue(success);
    }

    function testFallbackETH() public {
        vm.deal(user1, 1 ether);

        vm.prank(user1);

        (bool success,) =
            address(walletGuard).call{value: 1 ether}(abi.encodeWithSignature("unknownFunction()"));

        assertTrue(success);
    }
}