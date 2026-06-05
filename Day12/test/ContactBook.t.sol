// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../contracts/ContactBook.sol";

contract ContactBookTest is Test{
    ContactBook private contactBook;
    address private user1 = address(1);
    address private user2 = address(2);

    function setUp() public{
        contactBook = new ContactBook();
    }

    function testOwnerSetCorrectly() public view{
        assertEq(contactBook.getOwner(), address(this));
    }

    function testAddContact() public{
        contactBook.addContact("Mitra","B",6374819018,"mitra@mail.in");
        assertEq(contactBook.getMyContactCount(),1);
        assertEq(contactBook.totalContact(),1);
    }

    function testStoreContactData() public{
        contactBook.addContact("Mitra","B",6374819018,"mitra@mail.in");
        ContactBook.Contact[] memory contacts = contactBook.getMyContact();
        assertEq(contacts.length, 1);
        assertEq(contacts[0].fname, "Mitra");
        assertEq(contacts[0].lname, "B");
        assertEq(contacts[0].mobileNo, 6374819018);
        assertEq(contacts[0].emailAddress, "mitra@mail.in");
    }

    function testDuplicateContact() public{
        contactBook.addContact("Mitra","B",6374819018,"mitra@mail.in");
        vm.expectRevert(CONTACTBOOK_EXISTINGUSER.selector);
        contactBook.addContact("Jai","B",6374819018,"Jai@mail.in");
    }

    function testGetMyContactCount() public{
        contactBook.addContact("Mitra","B",6374819018,"mitra@mail.in");
        contactBook.addContact("Jai","B",6374819019,"Jai@mail.in");
        assertEq(contactBook.getMyContactCount(),2);
    }

    function testDeleteContact() public{
        contactBook.addContact("Mitra","B",6374819018,"mitra@mail.in");
        contactBook.deleteContact(0);
        assertEq(contactBook.getMyContactCount(),0);
    }

    function testDeleteMiddleContact() public{
        contactBook.addContact("Mitra","B",6374819018,"mitra@mail.in");
        contactBook.addContact("Jai","B",6374819019,"Jai@mail.in");
        contactBook.addContact("Rahul","B",6374819020,"Rahul@mail.in");
        contactBook.deleteContact(1);
        ContactBook.Contact[] memory contacts = contactBook.getMyContact();
        assertEq(contacts.length, 2);
        assertEq(contacts[0].fname, "Mitra");
        assertEq(contacts[1].fname, "Rahul");
    }

    function testDeleteInvalidIndex() public{
        contactBook.addContact("Mitra","B",6374819018,"mitra@mail.in");
        vm.expectRevert(CONTACTBOOK_INVALIDINDEX.selector);
        contactBook.deleteContact(5);
    }

    function testOwnerCanViewContacts() public{
        vm.prank(user1);
        contactBook.addContact("Mitra","B",6374819018,"mitra@mail.in");
        ContactBook.Contact[] memory contacts = contactBook.getUserContacts(user1);
        assertEq(contacts.length, 1);
        assertEq(contacts[0].fname, "Mitra");
    }

    function testNonOwnerCannotViewContacts() public{
        vm.prank(user1);
        vm.expectRevert(CONTACTBOOK_UNAUTHORIZEDACCESS.selector);
        contactBook.getUserContacts(user2);
    }

    function testOwnerCanDeleteUserContact() public{
        vm.startPrank(user1);
        contactBook.addContact("Mitra","B",6374819018,"mitra@mail.in");
        vm.stopPrank();
        contactBook.deleteUserContact(user1, 0);
        ContactBook.Contact[] memory contacts = contactBook.getUserContacts(user1);
        assertEq(contacts.length, 0);
    }

    function testNonOwnerCannotDeleteUserContact() public{
        vm.startPrank(user1);
        contactBook.addContact("Mitra","B",6374819018,"mitra@mail.in");
        vm.expectRevert(CONTACTBOOK_UNAUTHORIZEDACCESS.selector);
        contactBook.deleteUserContact(user2, 0);
        vm.stopPrank();
    }

    function testDeleteUserContactInvalidIndex() public{
        vm.expectRevert(CONTACTBOOK_INVALIDINDEX.selector);
        contactBook.deleteUserContact(user1, 0);
    }
}