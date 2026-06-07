// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

error UNAUTHORIZED_ACCESS();
error EXISTSING_USER();
error SELF_REFERRAL_FAILED();
error INVALID_REFERRAL_ADDRESS();
error INVALID_ETH_AMOUNT();
error PAYMENT_FAILED();
error ALREADY_REFFERRED();

contract ReferralSystem{

    address immutable i_owner;
    uint256 public totalRegisteredUser;
    uint256 public totalReferralCount;

    struct User{
        string fname;
        string lname;
        string emailAddress;
        uint256 timestamp;
    }

    mapping(address=>User) internal userData;
    mapping(address=>address[]) private userReferrals;
    mapping(address=>address) private referredBy;
    mapping(address=>bool) public isRegistered;

    event RegisteredUser(string fname, string lname, address indexed userAddress);
    event ReferralAdded(address indexed referrerAddress, address indexed userAddress);
    event UpdatedData(address indexed userAddress, string fname, string lname);
    event UserFunded(address indexed userAddress, uint256 indexed ethAmount);
    event ReceivedETH(address indexed senderAddress, uint256 indexed ethAmount);

    constructor(){
        i_owner = msg.sender;
    }

    modifier onlyOwner(){
        if(i_owner != msg.sender) revert UNAUTHORIZED_ACCESS();
        _;
    }

    // Registers a new user in the system
    function register(string memory _fname, string memory _lname, string memory _emailAddress) public{
        if(bytes(userData[msg.sender].emailAddress).length >0) revert EXISTSING_USER();
        User memory newUser = User(_fname, _lname, _emailAddress, block.timestamp);
        userData[msg.sender] = newUser;
        isRegistered[msg.sender] = true;
        totalRegisteredUser++;
        emit RegisteredUser(_fname, _lname, msg.sender);
    }

    // Allows users to update their personal information
    function updateMyData(string memory _fname, string memory _lname, string memory _emailAddress) public{
        User memory userNewData = User(_fname, _lname, _emailAddress, block.timestamp);
        userData[msg.sender] = userNewData;
        emit UpdatedData(msg.sender, _fname, _lname);
    }

    // Allows users to provide a referrer address 
    function referralAddressOptional(address _referrerAddress) public{
        if(_referrerAddress == msg.sender) revert SELF_REFERRAL_FAILED();
        if(_referrerAddress == address(0)) revert INVALID_REFERRAL_ADDRESS();
        if(referredBy[msg.sender] != address(0)) revert ALREADY_REFFERRED();
        referredBy[msg.sender] = _referrerAddress;
        userReferrals[_referrerAddress].push(msg.sender);
        totalReferralCount++;
        emit ReferralAdded(_referrerAddress, msg.sender);
    }

    // Returns user's data
    function getMyData() public view returns(User memory){
        return userData[msg.sender];
    }

    // Returns the referrer address of the caller
    function getReferrer() public view returns(address){
        return referredBy[msg.sender];
    }

    // Returns the list of referrals for the caller
    function getMyReferrals() public view returns(address[] memory){
        return userReferrals[msg.sender];
    }

    // Returns the total number of referrals for the caller
    function getMyTotalReferrals() public view returns(uint256){
        return userReferrals[msg.sender].length;
    }

    // Returns the owner of the contract
    function getOwner() public view returns(address){
        return i_owner;
    }

    // Allows the owner to fund a user's address with Ether
    function fundUser(address _userAddress) payable external onlyOwner{
        if(msg.value <= 0) revert INVALID_ETH_AMOUNT();
        (bool success, ) = payable(_userAddress).call{value: msg.value}("");
        if(!success) revert PAYMENT_FAILED();
        emit UserFunded(_userAddress, msg.value);
    }

    // Returns array of user's referrals
    function getUserReferrals(address _userAddress) public view onlyOwner returns(address[] memory){
        return userReferrals[_userAddress];
    }

    // Returns the data of a specific user
    function getUserData(address _userAddress) public view onlyOwner returns(User memory){
        return userData[_userAddress];
    }

    // Only owner can get all referral status of the system
    function getAllReferralStatus() public view onlyOwner returns(uint256 totalUser, uint256 totalReferrals){
        return (totalRegisteredUser, totalReferralCount);
    }

    // Receives ETH with no calldata
    receive() external payable {
        emit ReceivedETH(msg.sender, msg.value);
    }

    // Handles ETH sent with calldata
    fallback() external payable{
        emit ReceivedETH(msg.sender, msg.value);
    }

}