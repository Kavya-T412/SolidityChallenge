// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

error EMAILREGISTRY_UNAUTHORIZED_aCCESS();
error EMAILREGISTRY_EXISTING_USERNAME();
error EMAILREGISTRY_ACCESS_DENIED();
error EMAILREGISTRY_INACTIVE_CONTRACT();
error EMAILREGISTRY_INVALID_EMAIL_ID();
error EMAILREGISTRY_INVALID_USER_ADDRESS();

contract EmailRegistry {

    enum EmailStatus {
        Created,
        Active,
        Suspended,
        Banned
    }

    address private owner;
    uint128 public emailCount;
    bool private active;

    struct EmailEntry{
        uint256 id;
        string fname;
        string lname;
        uint256 dateOfBirth;
        string userName;
        EmailStatus status;
        uint256 timestamp;
    }

    mapping(uint256 => EmailEntry) private EmailId;
    mapping(uint256 => address) private creatorId;
    mapping(address => EmailEntry[]) private creatorEmails;
    mapping(string => bool) public userNameTaken;
    
    event EthReceived(address senderAddress, uint256 ethAmount);
    event EmailCreatedAndActivated(address indexed creatorAddress, uint256 indexed emailId, string fname, string userName);
    event EmailUpdated(address indexed creatorAddress, uint256 indexed updatedEmailId, string newFname, string newUserName);
    event UserNameFreed(string freeUserName);
    event EmailActivated(address indexed creatorAddress, uint256 emailId);
    event EmailSuspended(address indexed creatorAddress, uint256 emailId);
    event EmailBanned(address indexed creatorAddress, uint256 emailId);
    event UserNameDeleted(string deletedUserName);
    event EmailDeleted(address indexed creatorAddress, uint256 indexed emailId, string userName);
    event ContractOwnershipTransferred(address indexed ownerAddress, address indexed newOwnerAddress);
    event ContractActivated();
    event ContractDeactivated();

    constructor(){
        owner = msg.sender;
    }

    modifier onlyOwner(){
        if(msg.sender != owner) revert EMAILREGISTRY_UNAUTHORIZED_aCCESS();
        _;
    }

    // Activates and deactivates the contract
    modifier isActive(){
        if(!active) revert EMAILREGISTRY_INACTIVE_CONTRACT();
        _;
    }

    // Return true if contract is active, false otherwise
    function isContractActive() public view returns(bool){
        return active;
    }

    // Allows users to register their emails
    function register(string memory _fname, string memory _lname, uint256 _dateOfBirth, string memory _userName) public isActive {
        if(userNameTaken[_userName] == true) revert EMAILREGISTRY_EXISTING_USERNAME();
        emailCount++;
        uint256 _id = emailCount;

        EmailEntry storage emailEntry = EmailId[_id]; // Pointer to the storage location of the email entry
        emailEntry.id = _id;
        emailEntry.fname = _fname;
        emailEntry.lname = _lname;  
        emailEntry.dateOfBirth = _dateOfBirth;
        emailEntry.userName = _userName;
        emailEntry.status = EmailStatus.Active;
        emailEntry.timestamp = block.timestamp;

        userNameTaken[_userName] = true;
        creatorEmails[msg.sender].push(emailEntry); // Store's the creator's email
        creatorId[_id] = msg.sender; // Maps the email ID to the creator's address

        emit EmailCreatedAndActivated(msg.sender, _id, _fname, _userName);
    }

    // Allows users to update their mail
    function updateEmail(uint256 _id, string memory _newFname, string memory _newLname, uint256 _newDateOfBirth, string memory _newUserName) public isActive {
        if(creatorId[_id] != msg.sender) revert EMAILREGISTRY_ACCESS_DENIED();
        string memory oldUserName = EmailId[_id].userName;

        // Checks the updated username is new and not taken by another user
        if(keccak256(bytes(_newUserName)) != (keccak256(bytes(oldUserName))) && userNameTaken[_newUserName]) revert EMAILREGISTRY_EXISTING_USERNAME();
        userNameTaken[oldUserName] = false;
        
        EmailEntry storage newEmailEntry = EmailId[_id];
        newEmailEntry.fname = _newFname;
        newEmailEntry.lname = _newLname;
        newEmailEntry.dateOfBirth = _newDateOfBirth;
        newEmailEntry.userName = _newUserName;
        newEmailEntry.status = EmailStatus.Active;
        newEmailEntry.timestamp = block.timestamp;

        userNameTaken[_newUserName] = true;

        EmailEntry[] storage id = creatorEmails[msg.sender];
        uint256 indexToUpdate = 0; 
        // Finds the index of the email entry to update in the creator's email array
        for(uint256 i=0; i<id.length; i++){
            if(id[i].id == _id){
                indexToUpdate = i;
                break;
            }
        } //Store's the creator's updated email
        creatorId[_id] = msg.sender; // Maps the email ID to the creator's address
        creatorEmails[msg.sender][indexToUpdate] = newEmailEntry; // Updates the email entry in the creator's email array

        emit UserNameFreed(oldUserName);
        emit EmailUpdated(msg.sender, _id, _newFname, _newUserName);
    }

    // Allows users to suspend their email
    function suspendMyEmail(uint256 _id) external isActive{
        EmailEntry storage emailEntry = EmailId[_id];
        if(creatorId[_id] != msg.sender) revert EMAILREGISTRY_INVALID_EMAIL_ID();
        emailEntry.status = EmailStatus.Suspended; 
        emit EmailSuspended(msg.sender, _id);
    }

    // Allows users to delete their email
    function deleteMyEmail(uint256 _id, string memory _userName) public isActive{
        if(creatorId[_id] != msg.sender) revert EMAILREGISTRY_INVALID_EMAIL_ID();
        delete EmailId[_id];
        delete creatorId[_id];

        EmailEntry[] storage emailEntry = creatorEmails[msg.sender];
        uint256 indexToDelete = 0;
        // Finds the index of the email entry to delete in the creator's email array
        for(uint256 i=0; i<emailEntry.length; i++){
            if(emailEntry[i].id == _id){
                indexToDelete = i;
                break;
            }
        }
        // Shifts the email entries after the deleted entry to fill the gap
        for(uint256 i = indexToDelete; i<emailEntry.length-1; i++){
            emailEntry[i] = emailEntry[i+1];
        }
        emailEntry.pop();
        userNameTaken[_userName] = false;

        unchecked {
            emailCount--;
        }

        emit EmailDeleted(msg.sender, _id, _userName);
    }

    // Allows users to check the status of their email
    function checkMyEmailStatus(uint256 _id) public view returns(EmailStatus){
        if(creatorId[_id] != msg.sender) revert EMAILREGISTRY_ACCESS_DENIED();
        EmailEntry memory emailEntry = EmailId[_id];
        return emailEntry.status;
    }

    // Allows users to view their email details
    function getMyEmail() public view returns (EmailEntry[] memory){
        return creatorEmails[msg.sender];
    }

    // Returns the contract owner's address
    function getOwner() public view returns(address){
        return owner;
    }

    // Allows the owner to view any email by its ID
    function getEmailById(uint256 _id) external view onlyOwner returns(EmailEntry memory){
        return EmailId[_id];
    }

    // Owner can activate the creator's email 
    function activateCreatorEmail(address _creatorAddress, uint256 _emailId) external isActive onlyOwner{
        EmailEntry storage emailEntry = EmailId[_emailId];
        if(creatorId[_emailId] != _creatorAddress) revert EMAILREGISTRY_INVALID_EMAIL_ID();
        emailEntry.status = EmailStatus.Active;
        emit EmailActivated(_creatorAddress, _emailId);
    }

    // Owner can suspend the creator's email
    function suspendCreatorEmail(address _creatorAddress, uint256 _emailId) external onlyOwner isActive{
        EmailEntry storage emailEntry = EmailId[_emailId];
        if(creatorId[_emailId] != _creatorAddress) revert EMAILREGISTRY_INVALID_EMAIL_ID();
        emailEntry.status = EmailStatus.Suspended;
        emit EmailSuspended(_creatorAddress, _emailId);
    }

    // Owner can ban the creator's email
    function banCreatorEmail(address _creatorAddress, uint256 _emailId) external onlyOwner isActive{
        EmailEntry storage emailEntry = EmailId[_emailId];
        if(creatorId[_emailId] != _creatorAddress) revert EMAILREGISTRY_INVALID_EMAIL_ID();
        emailEntry.status = EmailStatus.Banned;
        emit EmailBanned(_creatorAddress, _emailId);
    }

    // Allows the owner to view all email IDs created by a specific creator
    function getCreatorEmailIds(address _creatorAddress) external view onlyOwner returns(uint256[] memory){
        EmailEntry[] memory emails = creatorEmails[_creatorAddress];
        uint256[] memory ids = new uint256[](emails.length);
        for(uint256 i=0; i<emails.length; i++){
            ids[i] = emails[i].id;
        }
        return ids;
    }

    // Allows the owner to check the status of any email 
    function checkCreatorEmailStatus(address _creatorAddress, uint256 _id) external view onlyOwner returns(EmailStatus){
        if(creatorId[_id] != _creatorAddress) revert EMAILREGISTRY_INVALID_EMAIL_ID();
        EmailEntry memory emailEntry = EmailId[_id];
        return emailEntry.status;
    }

    // Allows the owner to view all email details created by a specific creator
    function getCreatorEmails(address _creatorAddress) external view onlyOwner returns (EmailEntry[] memory){
        return creatorEmails[_creatorAddress];
    }

    // Allows the owner to delete any username
    function deleteCreatorUserName(string memory _userName) external onlyOwner isActive{
        userNameTaken[_userName] = false;
        emit UserNameDeleted(_userName);
    }

    // Allows the owner to delete any email
    function deleteUserEmail(address _creatorAddress, uint256 _emailId, string memory _userName) external onlyOwner isActive{
        if(creatorId[_emailId] != _creatorAddress) revert EMAILREGISTRY_ACCESS_DENIED();
        delete EmailId[_emailId];
        delete creatorId[_emailId];
        EmailEntry[] storage emailEntry = creatorEmails[_creatorAddress];
        uint256 indexToDelete = 0;
        for(uint256 i=0; i<emailEntry.length; i++){
            if(emailEntry[i].id == _emailId){
                indexToDelete = i;
                break;
            }
        }
        for(uint256 i = indexToDelete; i<emailEntry.length-1; i++){
            emailEntry[i] = emailEntry[i+1];
        }
        emailEntry.pop();
        userNameTaken[_userName] = false;
        unchecked {
            emailCount--;
        }
        emit EmailDeleted(_creatorAddress, _emailId, _userName);
    }

    // Allows the owner to transfer contract ownership to a new owner
    function transferOwnership(address _userAddress) external onlyOwner{
        if(_userAddress == address(0)) revert EMAILREGISTRY_INVALID_USER_ADDRESS();
        owner = _userAddress;
        emit ContractOwnershipTransferred(owner, _userAddress);
    }

    // Allows the owner to renounce ownership of the contract
    function renounceOwnership() external onlyOwner isActive{
        owner = address(0);
        emit ContractOwnershipTransferred(owner, address(0));
    }

    // Allows the owner to activate the contract
    function activateContract() external onlyOwner{
        active = true;
        emit ContractActivated();
    }

    // Allows the owner to deactivate the contract
    function deactivateContract() external onlyOwner{
        active = false;
        emit ContractDeactivated();
    }

    // Fallback and receive functions to accept Ether
    receive() external payable{
        emit EthReceived(msg.sender, msg.value);
    }

    fallback() external payable{
        emit EthReceived(msg.sender, msg.value);
    }

}