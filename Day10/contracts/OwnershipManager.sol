// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

error UNAUTHORIZED_ACCESS();
error INVALID_ADDRESS();

contract OwnershipManager{
    address private owner;
    struct Data{
        string fname;
        string lname;
        uint256 timestamp;
    }

    mapping (address => Data) private ownerData;

    event OwnershipTransferred(address indexed newOwnerAddress);
    event OwnershipRenounced(address indexed addressZero);
    event NewOwnerData(string indexed fname, string lname);

    constructor(){
        owner = msg.sender;
    }

    modifier onlyOwner(){
        if(owner != msg.sender) revert UNAUTHORIZED_ACCESS();
        _;
    }

    function transferOwnership(address _newOwnerAddress) public onlyOwner{
        if(_newOwnerAddress == address(0)) revert INVALID_ADDRESS();
        owner = _newOwnerAddress;
        emit OwnershipTransferred(_newOwnerAddress);
    }

    function renounceOwnership() public onlyOwner{
        owner = address(0);
        emit OwnershipRenounced(address(0));
    }

    function changeOwnerData(string memory _fname, string memory _lname) public onlyOwner{
        Data memory data = Data(_fname, _lname, block.timestamp);
        ownerData[owner] = data;
        emit NewOwnerData(_fname, _lname);
    }

    function getOwner() public view returns(address){
        return owner;
    }

    function getOwnerData() public view returns(string memory, string memory, address, uint256){
        Data memory data = ownerData[owner];
        return(data.fname, data.lname, owner, data.timestamp);
    }

    function getContractSummary() public view returns(string memory, string memory, address){
        Data memory data = ownerData[owner];
        return(data.fname, data.lname, owner);
    }
}