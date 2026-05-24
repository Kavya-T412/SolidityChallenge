//SPDX-License-Identifier: MIT
pragma solidity ^0.8.28 ;

contract QuoteStore{

    uint256 quoteCount; //stores the number of quotes
    struct Quote{
        string author;
        string description;
        uint256 addAt;
    }

    mapping(address=>Quote) private userQuotes; //maps user address to their quote
    address[] private userAddress; //stores user address

    // allows users to store the quote
    function storeQuote(string memory _author, string memory _description) public {
        if(bytes(userQuotes[msg.sender].author).length == 0){
            userAddress.push(msg.sender); //add user address to the list if it's their first quote
            quoteCount++;
        }
        userQuotes[msg.sender] = Quote(_author, _description, block.timestamp); 
    }

    //enable users to view their quotes
    function myQuote() public view returns (string memory author, string memory description, uint256 timestamp){
        Quote memory quote = userQuotes[msg.sender];
        return (quote.author, quote.description, quote.addAt);
    }

    //allows users to update their quote
    function updateQuote (string memory _newAuthor, string memory _newDescription) public{
        userQuotes[msg.sender] = Quote(_newAuthor, _newDescription, block.timestamp);
    }

    //allows to delete the quote
    function deleteQuote () public {
        delete userQuotes[msg.sender];
    }

    //allows users to view other's quote
    function viewQuote(address _user) public view returns (string memory author, string memory description, uint256 timestamp){
        Quote memory userQuote = userQuotes[_user];
        return(userQuote.author, userQuote.description, userQuote.addAt);
    }

    //allows user to view the timestamp of the provided address
    function retriveTimestamp(address _user) public view returns (uint256 timestamp){
        return userQuotes[_user].addAt;
    }


}