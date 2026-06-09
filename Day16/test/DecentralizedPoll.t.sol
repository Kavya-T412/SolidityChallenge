// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../contracts/DecentralizedPoll.sol";

contract DecentralizedPollTest is Test {
    DecentralizedPoll private poll;

    address private user1 = address(1);
    address private user2 = address(2);

    function setUp() public {
        poll = new DecentralizedPoll();
        poll.activateContract();
    }

    function getOptions() internal pure returns(string[] memory options) {
        options = new string[](2);
        options[0] = "Yes";
        options[1] = "No";
    }

    function getUpdatedOptions() internal pure returns(string[] memory options) {
        options = new string[](3);
        options[0] = "Option A";
        options[1] = "Option B";
        options[2] = "Option C";
    }

    function testOwnerSetCorrectly() public view {
        assertEq(poll.getOwner(), address(this));
    }

    function testCreatePoll() public {
        poll.createPoll(
            "Election",
            "Choose a candidate",
            getOptions()
        );

        assertEq(poll.pollCount(), 1);
        assertEq(poll.getPollCreator(1), address(this));

        uint256[] memory ids = poll.getAllPolls();
        assertEq(ids.length, 1);
        assertEq(ids[0], 1);
    }

    function testCreateMultiplePolls() public {
        poll.createPoll("Poll 1", "Desc", getOptions());
        poll.createPoll("Poll 2", "Desc", getOptions());

        assertEq(poll.pollCount(), 2);

        uint256[] memory ids = poll.getAllPolls();
        assertEq(ids.length, 2);
    }

    function testRevertIfLessThanTwoOptions() public {
        string[] memory options = new string[](1);
        options[0] = "Only Option";

        vm.expectRevert(
            DECENTRALIZEDPOLL_MINIMUM_OF_TWO_OPTIONS_REQUIRED.selector
        );

        poll.createPoll(
            "Test",
            "Description",
            options
        );
    }

    function testGetPollOptions() public {
        poll.createPoll(
            "Election",
            "Choose",
            getOptions()
        );

        string[] memory options = poll.getPollOptions(1);

        assertEq(options.length, 2);
        assertEq(options[0], "Yes");
        assertEq(options[1], "No");
    }

    function testUpdatePoll() public {
        poll.createPoll(
            "Old Title",
            "Old Description",
            getOptions()
        );

        poll.updatePoll(
            1,
            "New Title",
            "New Description",
            getUpdatedOptions()
        );

        string[] memory options = poll.getPollOptions(1);

        assertEq(options.length, 3);
        assertEq(options[0], "Option A");
        assertEq(options[1], "Option B");
        assertEq(options[2], "Option C");
    }

    function testNonCreatorCannotUpdatePoll() public {
        poll.createPoll(
            "Title",
            "Description",
            getOptions()
        );

        vm.prank(user1);

        vm.expectRevert(
            DECENTRALIZEDPOLL_ACCESS_DENIED.selector
        );

        poll.updatePoll(
            1,
            "New",
            "New",
            getUpdatedOptions()
        );
    }

    function testDeletePoll() public {
        poll.createPoll(
            "Poll",
            "Description",
            getOptions()
        );

        poll.deletePoll(1);

        assertEq(poll.pollCount(), 0);
        assertEq(poll.getAllPolls().length, 0);
    }

    function testActivatePoll() public {
        poll.createPoll(
            "Election",
            "Choose",
            getOptions()
        );

        poll.activatePoll(1);

        vm.prank(user1);
        poll.vote(1, 0);

        uint256[] memory results = poll.getPollResults(1);

        assertEq(results[0], 1);
        assertEq(results[1], 0);
    }

    function testCannotActivateAlreadyActivePoll() public {
        poll.createPoll(
            "Election",
            "Choose",
            getOptions()
        );

        poll.activatePoll(1);

        vm.expectRevert(
            DECENTRALIZEDPOLL_POLL_IS_ACTIVE.selector
        );

        poll.activatePoll(1);
    }

    function testDeactivatePoll() public {
        poll.createPoll(
            "Election",
            "Choose",
            getOptions()
        );

        poll.activatePoll(1);
        poll.deactivatePoll(1);

        vm.prank(user1);

        vm.expectRevert(
            DECENTRALIZEDPOLL_INACTIVE_POLL.selector
        );

        poll.vote(1, 0);
    }

    function testVoteSuccessfully() public {
        poll.createPoll(
            "Election",
            "Choose",
            getOptions()
        );

        poll.activatePoll(1);

        vm.prank(user1);
        poll.vote(1, 0);

        uint256[] memory results = poll.getPollResults(1);

        assertEq(results[0], 1);
        assertEq(results[1], 0);
    }

    function testMultipleUsersCanVote() public {
        poll.createPoll(
            "Election",
            "Choose",
            getOptions()
        );

        poll.activatePoll(1);

        vm.prank(user1);
        poll.vote(1, 0);

        vm.prank(user2);
        poll.vote(1, 0);

        uint256[] memory results = poll.getPollResults(1);

        assertEq(results[0], 2);
    }

    function testPreventDoubleVoting() public {
        poll.createPoll(
            "Election",
            "Choose",
            getOptions()
        );

        poll.activatePoll(1);

        vm.startPrank(user1);

        poll.vote(1, 0);

        vm.expectRevert(
            DECENTRALIZEDPOLL_USER_HAS_VOTED.selector
        );

        poll.vote(1, 1);

        vm.stopPrank();
    }

    function testInvalidOptionIndex() public {
        poll.createPoll(
            "Election",
            "Choose",
            getOptions()
        );

        poll.activatePoll(1);

        vm.prank(user1);

        vm.expectRevert(
            DECENTRALIZEDPOLL_INVALID_OPTION_INDEX.selector
        );

        poll.vote(1, 5);
    }

    function testVoteOnInactivePoll() public {
        poll.createPoll(
            "Election",
            "Choose",
            getOptions()
        );

        vm.prank(user1);

        vm.expectRevert(
            DECENTRALIZEDPOLL_INACTIVE_POLL.selector
        );

        poll.vote(1, 0);
    }

    function testGetPollResults() public {
        poll.createPoll(
            "Election",
            "Choose",
            getOptions()
        );

        poll.activatePoll(1);

        vm.prank(user1);
        poll.vote(1, 0);

        vm.prank(user2);
        poll.vote(1, 1);

        uint256[] memory results = poll.getPollResults(1);

        assertEq(results.length, 2);
        assertEq(results[0], 1);
        assertEq(results[1], 1);
    }

    function testGetMyPolls() public {
        poll.createPoll(
            "Poll One",
            "Description",
            getOptions()
        );

        DecentralizedPoll.PollData[] memory myPolls =
            poll.getMyPolls();

        assertEq(myPolls.length, 1);
        assertEq(myPolls[0].pollId, 1);
    }

    function testOwnerCanDeleteUserPoll() public {
        vm.startPrank(user1);

        poll.createPoll(
            "User Poll",
            "Description",
            getOptions()
        );

        vm.stopPrank();

        poll.deletePoll(user1, 1);

        assertEq(poll.pollCount(), 0);
    }

    function testCannotDeleteOtherUsersPoll() public {
        vm.startPrank(user1);

        poll.createPoll(
            "User Poll",
            "Description",
            getOptions()
        );

        vm.stopPrank();

        vm.prank(user2);

        vm.expectRevert(
            DECENTRALIZEDPOLL_ACCESS_DENIED.selector
        );

        poll.deletePoll(1);
    }

    function testContractDeactivation() public {
        poll.deactivateContract();

        vm.expectRevert(
            DECENTRALIZEDPOLL_INACTIVE_CONTRACT.selector
        );

        poll.createPoll(
            "Poll",
            "Description",
            getOptions()
        );
    }
}