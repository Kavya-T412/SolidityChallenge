// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

error OPTIMIZEDGASSAVER_UNAUTHORIZED_ACCESS();
error OPTIMIZEDGASSAVER_ALREADY_REGISTERED();
error OPTIMIZEDGASSAVER_NOT_A_REGISTERED_USER();

/*  `error` is used instead of `require` to save gas by reverting the transaction with custom error messages when certain conditions are not met. 
    Custom errors are more gas efficient than string error messages in `require` statements.
*/

contract OptimizedGasSaver {

    address immutable i_owner;
    
    /* Insted of using multiple string variable to store user data, `struct` is used to reduce gas costs 
       Allows to store the data using single function
       Ensures that data is organized and secured in a single variable
    */

    // Groups user data
    struct Data{
        bytes16 fName;
        bytes16 mName;
        bytes16 lName;
        uint8 age;
    }

    mapping(address => Data) internal userData; // maps user's address to their data
    mapping(address => bool) internal registeredUser; // maps user's address to their registration status

    event Registered(address indexed userAddress, bytes16 fName, bytes16 lName); // Emits registered
    event Updated(address indexed userAddress, bytes16 newFName, bytes16 newLName); // Emits updated
    event Deleted(address indexed userAddress); // Emits deleted

    // Sets contract deployer as owner of the contract
    constructor(){
        i_owner = msg.sender;
    }

    // Restricts access to only owner of the contract
    modifier onlyOwner() {
        if(msg.sender != i_owner) revert OPTIMIZEDGASSAVER_UNAUTHORIZED_ACCESS();
        _;
    }

    // Allows user to register
    function register(bytes16 _fName, bytes16 _mName, bytes16 _lName, uint8 _age) external {
        if(registeredUser[msg.sender] == true) revert OPTIMIZEDGASSAVER_ALREADY_REGISTERED();

        Data memory data = Data(_fName, _mName, _lName, _age);
        userData[msg.sender] = data;
        registeredUser[msg.sender] = true;

        emit Registered(msg.sender, _fName, _lName);
    }

    // Allows users to update their data
    function update(bytes16 _newFName, bytes16 _newMName, bytes16 _newLName, uint8 _newAge) external {
        if(registeredUser[msg.sender] == false) revert OPTIMIZEDGASSAVER_NOT_A_REGISTERED_USER();

        Data storage data = userData[msg.sender];
        data.fName = _newFName;
        data.mName = _newMName;
        data.lName = _newLName;
        data.age = _newAge;

        emit Updated(msg.sender, _newFName, _newLName);
    }

    // Deletes user data
    function deleteMyData() external {
        delete userData[msg.sender];
        registeredUser[msg.sender] = false;

        emit Deleted(msg.sender);
    } 

    // Returns user's data
    function getMyData() external view returns (Data memory){
        return userData[msg.sender];
    }

    // Returns contract owner
    function getOwner() external view returns (address) {
        return i_owner;
    }

    // Returns user's data, accessed only by contract owner
    function getUserData (address _userAddress) external view onlyOwner returns(Data memory){
        return userData[_userAddress];
    }
}





/* Basic storage of user data in blockchain using smart contract which is not optimized for gas usage.

contract unOptimized{

    string public fName;
    string public lName;
    uint256 public age;

    function register(string memory _fName, string memory _lName, uint256 _age) external {
        require(bytes(fName).length == 0 && bytes(lName).length == 0, "User already registered");
        fName = _fName;
        lName = _lName;
        age = _age;
    }

    function update(string memory _newFName, string memory _newLName, uint256 _newAge) external {
        require(bytes(fName).length != 0 && bytes(lName).length != 0, "User not registered");
        fName = _newFName;
        lName = _newLName;
        age = _newAge;
    }

}

*/