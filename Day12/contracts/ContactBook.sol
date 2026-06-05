// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

error CONTACTBOOK_UNAUTHORIZEDACCESS();
error CONTACTBOOK_EXISTINGUSER();
error CONTACTBOOK_INVALIDINDEX();

contract ContactBook{
    address private owner;
    uint256 public totalContact;

    struct Contact{
        string fname;
        string lname;
        uint256 mobileNo;
        string emailAddress;
        uint256 timestamp;
    }

    mapping (address => Contact[]) private contactInfo;

    event ContactAdded(string indexed fname, string lname, uint256 mobileNo, string emailAddress);
    event ContactDeleted(address indexed userAddress, uint256 indexNo);

    constructor(){
        owner = msg.sender;
    }

    modifier onlyOwner(){
        if(owner!=msg.sender) revert CONTACTBOOK_UNAUTHORIZEDACCESS();
        _;
    }

    // Add contatct info
    function addContact(string memory _fname, string memory _lname, uint256 _mobileNo, string memory _emailAddress) public{
        Contact[] storage contact = contactInfo[msg.sender];
        for(uint256 i=0; i<contact.length; i++){
            if(contact[i].mobileNo == _mobileNo) revert CONTACTBOOK_EXISTINGUSER();
        }

        Contact memory newContact = Contact(_fname, _lname, _mobileNo, _emailAddress, block.timestamp);
        contact.push(newContact);
        emit ContactAdded(_fname, _lname, _mobileNo, _emailAddress);
        totalContact++;
    }

    // Get contacts of user
    function getMyContact() public view returns(Contact[] memory){
        Contact[] memory contact = contactInfo[msg.sender];
        return contact;
    }

    // Gets user's contact counts
    function getMyContactCount() public view returns(uint256){
        return contactInfo[msg.sender].length;
    }

    // Delete contact by index
    function deleteContact(uint256 _contactIndex) public{
        Contact[] storage contact = contactInfo[msg.sender];
        if(_contactIndex >= contact.length) revert CONTACTBOOK_INVALIDINDEX();
        for (uint256 i= _contactIndex; i<contact.length-1;i++){
            contact[i] = contact[i+1];
        }
        contact.pop();
        emit ContactDeleted(msg.sender, _contactIndex);
    }

    // Get contract owner
    function getOwner() public view returns(address){
        return owner;
    }

    // Delete contact of any user by owner
    function deleteUserContact(address _userAddress, uint256 _contactIndex) public onlyOwner{
        Contact[] storage contact = contactInfo[_userAddress];
        if(_contactIndex>=contact.length) revert CONTACTBOOK_INVALIDINDEX();
        for(uint256 i = _contactIndex; i<contact.length-1; i++){
            contact[i] = contact[i+1];
        }
        contact.pop();
    }

    // Get any user's contact by owner
    function getUserContacts(address _userAddress) public onlyOwner view returns(Contact[] memory){
        return contactInfo[_userAddress];
    }
}