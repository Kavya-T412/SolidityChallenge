// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

error NFTVAULT_UNAUTHORIZEDACCESS();
error NFTVAULT_EXISTING_NFT();
error NFTVAULT_INVALIDINDEX();

contract NFTVault{
    address immutable i_owner;
    uint256 public totalNFTs;
    uint256 public totalUpdatedNFTs;

    struct NFT{
        string name;
        string description;
        string imgUrl;
        uint256 nftId;
        address contractAddress;
        uint256 timestamp;
    }

    mapping(address => NFT[]) internal nftsInfo;

    event NftStored(string indexed name, uint256 indexed nftId, address indexed contractAddress, address userAddress);
    event NftUpdated(uint256 nftIndexed, string indexed name, uint256 indexed nftId, address indexed contractAddress);
    event NftDeleted(uint256 indexed nftIndex, address indexed userAddress);

    constructor(){
        i_owner = msg.sender;
    }

    modifier onlyOwner(){
        if(i_owner != msg.sender) revert NFTVAULT_UNAUTHORIZEDACCESS();
        _;
    }

    // Store Nft info
    function storeNFT(string memory _name, string memory _description, string memory _imgUrl, uint256 _nftId, address _contractAddress) public {
        NFT[] storage nft = nftsInfo[msg.sender];
        for(uint256 i = 0; i < nft.length; i++){
            if(nft[i].nftId == _nftId && nft[i].contractAddress == _contractAddress){
                revert NFTVAULT_EXISTING_NFT();
            }
        }
        NFT memory newNft = NFT(_name, _description, _imgUrl, _nftId, _contractAddress, block.timestamp);
        nftsInfo[msg.sender].push(newNft);
        emit NftStored(_name, _nftId, _contractAddress, msg.sender);
        totalNFTs++;
    }

    // Gets Nft info
    function getMyNFTs() public view returns(NFT[] memory){
        return nftsInfo[msg.sender];
    }

    // Gets Nft info at index
    function getMyNFTAtIndex(uint256 _nftIndex) public view returns(NFT memory){
        NFT[] memory nft = nftsInfo[msg.sender];
        if(_nftIndex >= nft.length) revert NFTVAULT_INVALIDINDEX();
        return nftsInfo[msg.sender][_nftIndex];
    }

    // Update Nft info at index
    function updateNFT(uint256 _nftIndex, string memory _name, string memory _description, string memory _imgUrl, uint256 _nftId, address _contractAddress) public{
        NFT[] storage nft = nftsInfo[msg.sender];
        for(uint256 i=0; i<nft.length; i++){
            if(nft[i].nftId == _nftId) revert NFTVAULT_EXISTING_NFT();
        }
        NFT memory updateNft = NFT(_name, _description, _imgUrl, _nftId, _contractAddress, block.timestamp);
        nft[_nftIndex] = updateNft;
        emit NftUpdated(_nftIndex, _name, _nftId, _contractAddress);
        totalUpdatedNFTs++;
    }

    // Delete Nft info at index
    function deleteNft(uint256 _nftIndex) public{
        NFT[] storage nft = nftsInfo[msg.sender];
        if(_nftIndex >= nft.length) revert NFTVAULT_INVALIDINDEX();
        for(uint256 i = _nftIndex; i< nft.length-1; i++){
            nft[i] = nft[i+1];
        }
        nft.pop();
        emit NftDeleted(_nftIndex, msg.sender);
    }

    // Get total Nfts stored by user
    function getMyTotalNfts() public view returns (uint256) {
        return nftsInfo[msg.sender].length;
    }

    // Retrives owner address
    function getOwner() public view returns (address) {
        return i_owner;
    }

    // Retrives Nft info of a user by owner
    function getUserNFTs(address _userAddress) public onlyOwner view returns(NFT[] memory) {
        return nftsInfo[_userAddress];
    }

    // Retrives Nft info at index of a user by owner
    function getUserNFTAtIndex(address _userAddress, uint256 _nftIndex) public onlyOwner view returns(NFT memory){
        NFT[] memory nft = nftsInfo[_userAddress];
        if(_nftIndex >= nft.length) revert NFTVAULT_INVALIDINDEX();
        return nftsInfo[_userAddress][_nftIndex];
    }

    // Get total Nfts stored by user by owner
    function getUserTotalNfts(address _userAddress) public onlyOwner view returns (uint256) {
        return nftsInfo[_userAddress].length;
    }

    // Delete Nft info at index of a user by owner
    function deleteUserNFT(address _userAddress, uint256 _nftIndex) public onlyOwner {
        NFT[] storage nft = nftsInfo[_userAddress];
        if (_nftIndex >= nft.length) revert NFTVAULT_INVALIDINDEX();
        for(uint256 i = _nftIndex; i < nft.length - 1; i++) {
            nft[i] = nft[i + 1];
        }
        nft.pop(); // Removes the last duplicate element after shifting
        emit NftDeleted(_nftIndex, _userAddress);
    }
}