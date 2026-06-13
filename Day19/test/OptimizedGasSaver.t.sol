// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {OptimizedGasSaver} from "../contracts/OptimizedGasSaver.sol";

contract OptimizedGasSaverTest is Test {
    OptimizedGasSaver optimizedGasSaver;

    address owner = address(this);
    address user1 = address(0x1);
    address user2 = address(0x2);

    function setUp() public {
        optimizedGasSaver = new OptimizedGasSaver();
        vm.label(owner, "Owner");
        vm.label(user1, "User1");
        vm.label(user2, "User2");
    }

    function testConstructorSetsOwner() public {
        assertEq(optimizedGasSaver.getOwner(), owner);
    }

    function testRegister() public{
        vm.prank(user1);
        optimizedGasSaver.register("Kavya", "T", "Builder", 19);
    }

    function testUpdateMyData() public{
        vm.prank(user1);
        optimizedGasSaver.register("Kavya", "T", "Builder", 19);

        vm.prank(user1);
        optimizedGasSaver.update("Mitra", "B", "Developer", 20);

        vm.prank(user1);
        OptimizedGasSaver.Data memory data = optimizedGasSaver.getMyData();

        assertEq(data.fName, "Mitra");
        assertEq(data.mName, "B");
        assertEq(data.lName, "Developer");
        assertEq(data.age, 20);
    }

    function testForDeleteMyData() public {
        vm.prank(user1);
        optimizedGasSaver.register("Kavya", "T", "Builder", 19);

        vm.prank(user1);
        optimizedGasSaver.deleteMyData();

        vm.prank(user1);
        OptimizedGasSaver.Data memory data = optimizedGasSaver.getMyData();

        assertEq(data.fName, 0);
        assertEq(data.mName, 0);
        assertEq(data.lName, 0);
        assertEq(data.age, 0);
    }

    function testForGetMyData() public {
        vm.prank(user1);
        optimizedGasSaver.register("Kavya", "T", "Developer", 19);

        vm.prank(user1);
        OptimizedGasSaver.Data memory data = optimizedGasSaver.getMyData();

        assertEq(data.fName, "Kavya");
        assertEq(data.mName, "T");
        assertEq(data.lName, "Developer");
        assertEq(data.age, 19);
    }

    function testOnlyOwnerCanGetUsersData () public{
        vm.prank(user1);
        optimizedGasSaver.register("Kavya", "T", "Developer", 19);

        vm.prank(owner);
        OptimizedGasSaver.Data memory data = optimizedGasSaver.getUserData(user1);
        
        assertEq(data.fName, "Kavya");
        assertEq(data.mName, "T");
        assertEq(data.lName, "Developer");
        assertEq(data.age, 19);
    }

    function testUsersCantAccessOtherUsersData () public{
        vm.prank(user1);
        optimizedGasSaver.register("Kavya", "T", "Builder", 19);

        vm.expectRevert();
        vm.prank(user2);
        optimizedGasSaver.getUserData(user1);
    }

    function testgetOwner() public{
        address contractOwner = optimizedGasSaver.getOwner();
        assertEq(contractOwner, owner);
    }
}