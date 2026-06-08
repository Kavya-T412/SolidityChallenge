// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

error WALLETGUARD_UNAUTHORIZED_ACCESS();
error WALLETGUARD_INVALID_ADDRESS();
error WALLETGUARD_ALREADY_REGISTERED();
error WALLETGUARD_ACCESS_DENIED();
error WALLETGUARD_PAUSED_CONTRACT();
error WALLETGUARD_INVALID_INDEX();
error WALLETGUARD_INVALID_ETH_AMOUNT();
error WALLETGUARD_TRANSFER_FAILED();
error WALLETGUARD_ALREADY_WHITELISTED();

contract WalletGuard {
    address immutable owner;
    uint256 public addressCount;
    uint256 public safeAddressCount;
    bool isPaused;

    struct User{
        string fname;
        string lname;
        address userAddress;
        uint256 timestamp;
    }

    mapping(address => User) internal userData;
    mapping(address => address[]) internal whitelistedAddress;

    event Registered(string indexed fname, string indexed lname, address indexed userAddress);
    event NewWhitelistedAddress(address indexed userAddress, address indexed safeAddress);
    event SuspiciousETHReceived(address indexed senderAddress, uint256 indexed ethAmount);
    event sentETH(address indexed userAddress, uint256 ethAmount);
    event ActiveContract();
    event InActiveContract();

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner(){
        if(owner != msg.sender) revert WALLETGUARD_UNAUTHORIZED_ACCESS();
        _;
    }

    modifier isActive(){
        if(!isPaused) revert WALLETGUARD_PAUSED_CONTRACT();
        _;
    }

    function register(string memory _fname, string memory _lname, address _userAddress) public isActive {
        if(bytes(userData[msg.sender].fname).length > 0) revert WALLETGUARD_ALREADY_REGISTERED();
        if(_userAddress == address(0)) revert WALLETGUARD_INVALID_ADDRESS();
        User memory user = User(_fname, _lname, _userAddress, block.timestamp);
        userData[msg.sender] = user;
        addressCount++;
        emit Registered(_fname, _lname, _userAddress);
    }

    function whitelistAddress(address _safeAddress) public isActive {
        if(_safeAddress == address(0) || _safeAddress == msg.sender) revert WALLETGUARD_INVALID_ADDRESS();
        address[] storage list = whitelistedAddress[msg.sender];
        for(uint256 i=0; i<list.length; i++){
            if(list[i] == _safeAddress) revert WALLETGUARD_ALREADY_WHITELISTED();
        }
        list.push(_safeAddress);
        safeAddressCount++;
        emit NewWhitelistedAddress(msg.sender, _safeAddress);
    }

    function getMyWhitelistedAddress() public view isActive returns(address[] memory){
        return whitelistedAddress[msg.sender];
    }

    function updateWhitelistedAddress(uint256 _index, address _newSafeAddress) public isActive{
        if(_newSafeAddress == address(0) || _newSafeAddress == msg.sender) revert WALLETGUARD_INVALID_ADDRESS();
        if(_index >= whitelistedAddress[msg.sender].length) revert WALLETGUARD_INVALID_INDEX();
        whitelistedAddress[msg.sender][_index] = _newSafeAddress;
    }

    function sendETHToWhitelisted(address _userAddress) payable public onlyOwner isActive{
        address[] memory userWhitelist = whitelistedAddress[msg.sender];
        bool isSafe = false;
        for(uint256 i=0; i<userWhitelist.length; i++){
            if(userWhitelist[i] == _userAddress){
                isSafe = true;
                break;
            }
        }
        if(!isSafe){
            emit SuspiciousETHReceived(msg.sender, msg.value);
            revert WALLETGUARD_ACCESS_DENIED();
        }

        if(msg.value == 0) revert WALLETGUARD_INVALID_ETH_AMOUNT();
        (bool success, ) = payable(_userAddress).call{value:msg.value}("");
        if(!success) revert WALLETGUARD_TRANSFER_FAILED();
        emit sentETH(_userAddress, msg.value);
    }

    function getOwner() public view returns (address){
        return owner;
    }

    function activateContract() external onlyOwner{
        isPaused = true;
        emit ActiveContract();
    }

    function deactivateContract() external onlyOwner{
        isPaused = false;
        emit InActiveContract();
    }

    receive() payable external{
        emit SuspiciousETHReceived(msg.sender, msg.value);
    }

    fallback() payable external{
        emit SuspiciousETHReceived(msg.sender, msg.value);
    }
}