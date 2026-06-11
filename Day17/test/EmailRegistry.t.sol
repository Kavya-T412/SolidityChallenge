// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../contracts/EmailRegistry.sol";

contract EmailRegistryTest is Test {
    EmailRegistry private registry;

    address private user1 = address(1);
    address private user2 = address(2);

    function setUp() public{
        registry = new EmailRegistry();
        registry.activateContract();
    }

    function testOwnerSetCorrectly() public view{
        assertEq(registry.getOwner(), address(this));
    }

    function testContractActivated() public view {
        assertEq(registry.isContractActive(), true);
    }

    function testRegisterEmail() public{
        registry.register("Mitra","B",14112006,"mitra_b");
        assertEq(registry.emailCount(), 1);
        EmailRegistry.EmailEntry[] memory emails = registry.getMyEmail();
        assertEq(emails.length, 1);
        assertEq(emails[0].id, 1);
        assertEq(emails[0].userName, "mitra_b");
    }

    function testDuplicateUserNameReverts() public{
        registry.register("Mitra","B",14112006,"mitra_b");
        vm.prank(user1);
        vm.expectRevert(EMAILREGISTRY_EXISTING_USERNAME.selector);
        registry.register("John","D",10101990,"mitra_b");
    }

    function testUpdateEmail() public{
        registry.register("Mitra","B",14112006,"mitra_b");
        registry.updateEmail(1,"Mitra","B",14112006,"mitra_b_updated");
        EmailRegistry.EmailEntry[] memory emails = registry.getMyEmail();
        assertEq(emails[0].userName, "mitra_b_updated");
    }

    function testSuspendedMyEmail() public{
        registry.register("Mitra","B",14112006,"mitra_b");
        registry.suspendMyEmail(1);
        EmailRegistry.EmailStatus status = registry.checkMyEmailStatus(1);
        assertEq(uint256(status), 2);
    }

    function testDeleteMyEmail() public{
        registry.register("Mitra","B",14112006,"mitra_b");
        registry.deleteMyEmail(1,"mitra_b");
        assertEq(registry.emailCount(), 0);
        assertEq(registry.userNameTaken("mitra_b"), false);
        
    }

    function testOwnerCanActivateEmail() public{
        vm.startPrank(user1);
        registry.register("Mitra","B",14112006,"mitra_b");
        vm.stopPrank();
        registry.suspendCreatorEmail(user1,1);
        registry.activateCreatorEmail(user1,1);
        EmailRegistry.EmailStatus status = registry.checkCreatorEmailStatus(user1, 1);
        assertEq(uint256(status), 1);
    }

    function testOwnerCanBanEmail() public{
        vm.prank(user1);
        registry.register("Mitra","B",14112006,"mitra_b");
        registry.banCreatorEmail(user1,1);
        EmailRegistry.EmailStatus status = registry.checkCreatorEmailStatus(user1, 1);
        assertEq(uint256(status), 3);
    }

    function testNonOwnerCannotManageEmails() public{
        vm.prank(user1);
        vm.expectRevert(EMAILREGISTRY_UNAUTHORIZED_aCCESS.selector);
        registry.banCreatorEmail(user1,1);
    }

    function testOwnerCanDeleteUsername() public{
        registry.register("Mitra","B",14112006,"mitra_b");
        registry.deleteCreatorUserName("mitra_b");
        assertEq(registry.userNameTaken("mitra_b"), false);
    }

    function testOwnerCanDeleteUserEmail() public{
        vm.prank(user1);
        registry.register("Mitra","B",14112006,"mitra_b");
        registry.deleteUserEmail(user1,1,"mitra_b");
        assertEq(registry.emailCount(), 0);
        assertEq(registry.userNameTaken("mitra_b"), false);
    }

    function testTransferOwnership() public{
        registry.transferOwnership(user1);
        assertEq(registry.getOwner(), user1);
    }

    function testRenounceOwnership() public{
        registry.renounceOwnership();
        assertEq(registry.getOwner(), address(0));
    }

    function testDeactivateContract() public{
        registry.deactivateContract();
        assertEq(registry.isContractActive(), false);
    }

    function testCannotRegisterWhenInactive() public{
        registry.deactivateContract();
        vm.expectRevert(EMAILREGISTRY_INACTIVE_CONTRACT.selector);
        registry.register("Mitra","B",14112006,"mitra_b");
    }

    function testReceiveETH() public{
        (bool success,) = address(registry).call{value: 0.05 ether}("");
        assertTrue(success);
    }
} 