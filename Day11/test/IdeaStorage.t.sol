// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28; 

import "forge-std/Test.sol";
import "../contracts/IdeaStorage.sol";

contract IdeaStorageTest {
    IdeaStorage ideaStorage;

    function beforeEach() public{
        ideaStorage = new IdeaStorage();
    }

    function testOwnerSetCorrectly() public {
        beforeEach();
        assert(ideaStorage.getOwner() == address(this));
    }

    function testAddIdea() public{
        beforeEach();
        ideaStorage.addIdea("My first idea", "This is a description of my first idea.", true);
        assert(ideaStorage.getMyIdeaCount() == 1);
    }

    function testTotalIdeaIncrement() public{
        beforeEach();
        ideaStorage.addIdea("My first idea", "This is a description of my first idea.", true);
        assert(ideaStorage.totalIdea() == 1);
    }

    function testStoreIdeaData() public{
        beforeEach();
        ideaStorage.addIdea("Web3 startup", "Blockchain Project", true);
        IdeaStorage.Idea[] memory ideas = ideaStorage.getMyIdea();
        assert(keccak256(bytes(ideas[0].title)) == keccak256(bytes("Web3 startup")));
        assert (ideas[0].isPublic == true);
    }

    function testGetPublicIdeas() public {
        beforeEach();
        ideaStorage.addIdea("Public Idea", "This is a public idea.", true);
        ideaStorage.addIdea("Private Idea", "This is a private idea.", false);
        IdeaStorage.Idea[] memory ideas = ideaStorage.getUserPublicIdeas(address(this));
        assert(ideas.length == 1);
        assert (keccak256(bytes(ideas[0].title)) == keccak256(bytes("Public Idea")));  
    }

    function testDeleteIdea() public{
        beforeEach();
        ideaStorage.addIdea("Idea 1", "Description 1", true);
        ideaStorage.addIdea("Idea 2", "Description 2", true);
        ideaStorage.deleteIdea(0);
        assert(ideaStorage.getMyIdeaCount() == 1);
    }

    function testDeleteMiddleIdea() public{
        beforeEach();
        ideaStorage.addIdea("Idea 1", "Description 1", true);
        ideaStorage.addIdea("Idea 2", "Description 2", true);
        ideaStorage.addIdea("Idea 3", "Description 3", true);
        ideaStorage.deleteIdea(1);
        IdeaStorage.Idea[] memory ideas = ideaStorage.getMyIdea();
        assert(ideas.length == 2);
        assert(keccak256(bytes(ideas[0].title)) == keccak256(bytes("Idea 1")));
        assert(keccak256(bytes(ideas[1].title)) == keccak256(bytes("Idea 3")));
    }

    function testIdeaCount() public{
        beforeEach();
        ideaStorage.addIdea("Idea 1", "Description 1", true);
        ideaStorage.addIdea("Idea 2", "Description 2", false);
        ideaStorage.addIdea("Idea 3", "Description 3", true);
        assert(ideaStorage.getMyIdeaCount() == 3);
    }

    function testOwnerAddress() public{
        beforeEach();
        assert(ideaStorage.getOwner() == address(this));
    }

}