// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

error DECENTRALIZEDPOLL_UNAUTHORIZED_ACCESS();
error DECENTRALIZEDPOLL_MINIMUM_OF_TWO_OPTIONS_REQUIRED();
error DECENTRALIZEDPOLL_INACTIVE_CONTRACT();
error DECENTRALIZEDPOLL_ACCESS_DENIED();
error DECENTRALIZEDPOLL_NOT_AN_EXISTING_POLL();
error DECENTRALIZEDPOLL_NOT_USER_EXISTING_POLL();
error DECENTRALIZEDPOLL_POLL_IS_ACTIVE();
error DECENTRAILZEDPOLL_POLL_ALREADY_ENDED();
error DECENTRALIZEDPOLL_USER_HAS_VOTED();
error DECENTRALIZEDPOLL_INACTIVE_POLL();
error DECENTRALIZEDPOLL_INVALID_OPTION_INDEX();
error DECENTRALIZEDPOLL_NO_EXISTING_POLL();

contract DecentralizedPoll{

    address immutable i_owner;
    bool private active;
    uint256 public pollCount;
    uint256[] private pollIds;

    enum PollStatus{Created, Active, Ended}

    struct PollData{
        uint256 pollId;
        string title;
        string description;
        string[] options;
        uint256[] votes;
        PollStatus status;
        uint256 createdAt;
    }

    mapping(uint256 => PollData) public polls;
    mapping(uint256 => address) private pollCreator;
    mapping(uint256 => mapping(address => bool)) public hasVoted;
    mapping(address => PollData[]) private creatorPolls;

    event PollCreated(address indexed creatorAddress, string pollTitle, string pollDescription);
    event UpdatedPoll(address indexed userAddress, uint256 pollId, string newPollTitle, string newPollDescription);
    event PollDeleted(address indexed userAddress, uint256 pollId);
    event Voted(address indexed voterAddress, uint256 indexed pollId, uint256 indexed optionIndex);
    event PollActivated(uint256 indexed pollId);
    event PollDeactivated(uint256 indexed pollId);
    event ContractActivated();
    event ContractDeactivated();

    constructor(){
        i_owner = msg.sender;
    }

    modifier onlyOwner{
        if(msg.sender != i_owner) revert DECENTRALIZEDPOLL_UNAUTHORIZED_ACCESS();
        _;
    }

    modifier isActive(){
        if(!active) revert DECENTRALIZEDPOLL_INACTIVE_CONTRACT();
        _;
    }

    modifier validPoll(uint256 _pollId){
        if(polls[_pollId].pollId != _pollId) revert DECENTRALIZEDPOLL_NOT_AN_EXISTING_POLL();
        _;
    }

    function createPoll(string memory _title, string memory _description, string[] memory _options) public isActive{
        if(_options.length<2) revert DECENTRALIZEDPOLL_MINIMUM_OF_TWO_OPTIONS_REQUIRED();
        pollCount++;
        uint256 _pollId = pollCount;
        
        PollData storage data = polls[_pollId];
        data.pollId = _pollId;
        data.title = _title;
        data.description = _description;
        data.options = _options;
        data.votes = new uint256[](_options.length);
        data.status = PollStatus.Created;
        data.createdAt = block.timestamp;
       
        creatorPolls[msg.sender].push(data);
        pollCreator[_pollId] = msg.sender;
        pollIds.push(_pollId);
       
        emit PollCreated(msg.sender, _title, _description);
    }

    function updatePoll(uint256 _pollId, string memory _newTitle, string memory _newDescription, string[] memory _newOptions) public isActive{
        if(_newOptions.length < 2) revert DECENTRALIZEDPOLL_MINIMUM_OF_TWO_OPTIONS_REQUIRED();
        if(pollCreator[_pollId] != msg.sender) revert DECENTRALIZEDPOLL_ACCESS_DENIED();
        
        PollData storage data = polls[_pollId];
        data.pollId = _pollId;
        data.title = _newTitle;
        data.description = _newDescription; 
        data.options = _newOptions;
        data.votes = new uint256[](_newOptions.length);
        data.status = PollStatus.Created;
        data.createdAt = block.timestamp;

        emit UpdatedPoll(msg.sender, _pollId, _newTitle, _newDescription);
    }

    function deletePoll(uint256 _pollId) public isActive{
        if(pollCreator[_pollId] != msg.sender) revert DECENTRALIZEDPOLL_ACCESS_DENIED();
        delete polls[_pollId];
        unchecked{
            pollCount--;
        }
        for(uint256 i=0; i<pollIds.length; i++){
            if(pollIds[i] == _pollId){
                pollIds[i] = pollIds[pollIds.length-1];
                break;
            }
        }
        pollIds.pop();
        emit PollDeleted(msg.sender, _pollId);
    }

    function vote(uint256 _pollId, uint256 _optionIndex) public isActive validPoll(_pollId){
        PollData storage data = polls[_pollId];
        if(data.status != PollStatus.Active) revert DECENTRALIZEDPOLL_INACTIVE_POLL();
        if(hasVoted[_pollId][msg.sender] == true) revert DECENTRALIZEDPOLL_USER_HAS_VOTED();
        if(_optionIndex >= data.options.length) revert DECENTRALIZEDPOLL_INVALID_OPTION_INDEX();
        
        data.votes[_optionIndex]++;
        hasVoted[_pollId][msg.sender] = true;
        
        emit Voted(msg.sender, _pollId, _optionIndex);
    }

    function getPollOptions(uint256 _pollId) public validPoll(_pollId) view returns(string[] memory){
        return polls[_pollId].options;
    }

    function getMyPolls() public view returns(PollData[] memory){
        return creatorPolls[msg.sender];
    }

    function getAllPolls() public view returns(uint256[] memory){
        return pollIds;
    }

    function getPollResults(uint256 _pollId) public validPoll(_pollId) view returns(uint256[] memory){
        return polls[_pollId].votes;
    }

    function getPollCreator(uint256 _pollId) public view returns(address){
        return pollCreator[_pollId];
    }

    function getOwner() public view returns(address){
        return i_owner;
    }

    function activatePoll(uint256 _pollId) external isActive validPoll(_pollId){
        if(pollCreator[_pollId] != msg.sender) revert DECENTRALIZEDPOLL_ACCESS_DENIED();

        PollData storage existingPoll = polls[_pollId];
        if(existingPoll.status == PollStatus.Active) revert DECENTRALIZEDPOLL_POLL_IS_ACTIVE();
        existingPoll.status = PollStatus.Active;
        
        emit PollActivated(_pollId);
    }

    function deactivatePoll(uint256 _pollId) external isActive validPoll(_pollId){
        if(pollCreator[_pollId] != msg.sender) revert DECENTRALIZEDPOLL_ACCESS_DENIED();

        PollData storage existingPoll = polls[_pollId];
        if(existingPoll.status == PollStatus.Ended) revert DECENTRAILZEDPOLL_POLL_ALREADY_ENDED();
        existingPoll.status = PollStatus.Ended;
        
        emit PollDeactivated(_pollId);
    }

    function deletePoll(address _creatorAddress, uint256 _pollId) external onlyOwner isActive{
        if(pollCreator[_pollId] != _creatorAddress) revert DECENTRALIZEDPOLL_NOT_USER_EXISTING_POLL();
        delete polls[_pollId];

        unchecked{
            pollCount--;
        }

        for(uint i=0; i<pollIds.length; i++){
            if(pollIds[i] == _pollId){
                pollIds[i] = pollIds[pollIds.length-1];
                break;
            }
        }
        pollIds.pop();
        emit PollDeleted(_creatorAddress, _pollId);
    }

    function getCreatorPolls(address _creatorAddress) external onlyOwner isActive view returns(PollData[] memory){
        return creatorPolls[_creatorAddress];
    }

    function activateContract() external onlyOwner{
        active = true;
        emit ContractActivated();
    }

    function deactivateContract() external onlyOwner{
        active = false;
        emit ContractDeactivated();
    }


}