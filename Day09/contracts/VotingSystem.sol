// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

error VOTINGSYSTEM_UNAUTHORIZEDACCESS();
error VOTINGSYSTEM_EXISTINGVOTER();
error VOTINGSYSTEM_VOTERALREADYVOTED();
error VOTINGSYSTEM_EXIXTINGPROPOSAL();
error VOTINGSYSTEM_NOEXISTINGPROPOSAL();
error VOTINGSYSTEM_NOTANEXISTINGVOTER();

contract VotingSystem{

    address private owner;
    uint256 public totalVoters; // Records the number of registered voters
    uint256 public totalProposals; // Records the number of existing proposals

    struct Voter{
        string fname;
        string lname;
        bool hasVoted;
        uint256 timestamp;
    }

    struct Proposal {
        string title;
        string description;
        uint256 proposalId;
        uint256 timestamp;
    }

    mapping(address => Voter) private voterData; // Links voter's address to their info
    mapping(address => Proposal) private proposalData; // Links user's address to their voted proposal

    event newRegistedVoter(string indexed fname, string lname, address userAddress);
    event userHasVoted(address indexed userAddress);
    event newProposalCreated(string indexed title, string description, uint256 proposalId);

    constructor(){
        owner = msg.sender;
    }

    modifier onlyOwner(){
        if(msg.sender != owner) revert VOTINGSYSTEM_UNAUTHORIZEDACCESS();
        _;
    }

    // Only the owner can create a proposal
    function createAProposal(string memory _title, string memory _description, uint256 _proposalId) public onlyOwner{
        if(bytes(proposalData[owner].title).length != 0) revert VOTINGSYSTEM_EXIXTINGPROPOSAL();
        proposalData[owner] = Proposal(_title, _description, _proposalId, block.timestamp);
        totalProposals++;
        emit newProposalCreated(_title, _description, _proposalId);
    }

    // Checks if a user has voted by owner
    function getVoterStatus(address _userAddress) public view  onlyOwner returns(bool){
        return voterData[_userAddress].hasVoted;
    }

    // Stores voter's details
    function register(string memory _fname, string memory _lname) public{
        if(bytes(voterData[msg.sender].fname).length != 0) revert VOTINGSYSTEM_EXISTINGVOTER();
        voterData[msg.sender] = Voter(_fname, _lname, false, block.timestamp);
        totalVoters++;
        emit newRegistedVoter(_fname, _lname, msg.sender);
    }

    // Retrieves the proposal details
    function getProposalData(uint256 _proposalId) public view returns(string memory, string memory, uint256){
        if(bytes(proposalData[owner].title).length == 0) revert VOTINGSYSTEM_NOEXISTINGPROPOSAL();
        Proposal memory proposal = proposalData[owner];
        return(proposal.title, proposal.description, _proposalId);
    }

    // Allows a registered voter to cast their vote on the proposal
    function vote(string memory _title, string memory _description, uint256 _proposalId) public {
        if(bytes(voterData[msg.sender].fname).length == 0) revert VOTINGSYSTEM_NOTANEXISTINGVOTER();
        if(voterData[msg.sender].hasVoted == true) revert VOTINGSYSTEM_VOTERALREADYVOTED();
        if(bytes(proposalData[owner].title).length == 0) revert VOTINGSYSTEM_NOEXISTINGPROPOSAL();
        voterData[msg.sender].hasVoted = true;
        proposalData[msg.sender] = Proposal(_title, _description, _proposalId, block.timestamp);
        emit userHasVoted(msg.sender);
    }

    // Allows a voter to check if they have voted
    function getMyStatus() public view returns(bool){
        return voterData[msg.sender].hasVoted;
    }

    // gets the address of the contract owner
    function getOwner() public view returns(address){
        return owner;
    }
}