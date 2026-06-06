// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../contracts/NFTVault.sol";

contract NFTVaultTest is Test{
    NFTVault private nftVault;
    address private user1 = address(1);
    address private user2 = address(2);

    function setUp() public{
        nftVault = new NFTVault();
    }

    function testOwnerSetCorrectly() public view{
        assertEq(nftVault.getOwner(), address(this));
    }

    function testStoreNFT() public{
        nftVault.storeNFT("CryptoPunk","Rare NFT","ipfs://image",1,address(100));
        assertEq(nftVault.getMyTotalNfts(),1);
        assertEq(nftVault.totalNFTs(),1);
    }

    function testStoreNFTData() public{
        nftVault.storeNFT("CryptoPunk","Rare NFT","ipfs://image",1,address(100));
        NFTVault.NFT[] memory nfts = nftVault.getMyNFTs();
        assertEq(nfts.length,1);
        assertEq(nfts[0].name,"CryptoPunk");
        assertEq(nfts[0].description,"Rare NFT");
        assertEq(nfts[0].imgUrl,"ipfs://image");
        assertEq(nfts[0].nftId,1);
        assertEq(nfts[0].contractAddress,address(100));
    }

    function testDuplicateNFTReverts() public{
        nftVault.storeNFT("CryptoPunk","Rare NFT","ipfs://image",1,address(100));
        vm.expectRevert(NFTVAULT_EXISTING_NFT.selector);
        nftVault.storeNFT("CryptoPunk2","Rare NFT","ipfs://image2",1,address(100));
    }

    function testGetNFTAtIndex() public{
        nftVault.storeNFT("CryptoPunk","Rare NFT","ipfs://image",1,address(100));
        NFTVault.NFT memory nft = nftVault.getMyNFTAtIndex(0);
        assertEq(nft.name,"CryptoPunk");
        assertEq(nft.nftId,1);
    }

    function testGetNFTInvalidIndex() public{
        vm.expectRevert(NFTVAULT_INVALIDINDEX.selector);
        nftVault.getMyNFTAtIndex(0);
    }

    function testDeleteNFT() public{
        nftVault.storeNFT("NFT1","Desc","url",1,address(100));
        nftVault.deleteNft(0);
        assertEq(nftVault.getMyTotalNfts(),0);
    }

    function testDeleteMiddleNFT() public{
        nftVault.storeNFT("NFT1","Desc","url",1,address(100));
        nftVault.storeNFT("NFT2","Desc","url",2,address(200));
        nftVault.storeNFT("NFT3","Desc","url",3,address(300));
        nftVault.deleteNft(1);
        NFTVault.NFT[] memory nfts = nftVault.getMyNFTs();
        assertEq(nfts.length,2);
        assertEq(nfts[0].name,"NFT1");
        assertEq(nfts[1].name,"NFT3");
    }

    function testDeleteNFTInvalidIndex() public{
        vm.expectRevert(NFTVAULT_INVALIDINDEX.selector);
        nftVault.deleteNft(0);
    }

    function testOwnerCanViewUserNFTs() public{
        vm.prank(user1);
        nftVault.storeNFT("CryptoPunk","Rare NFT","url",1,address(100));
        NFTVault.NFT[] memory nfts = nftVault.getUserNFTs(user1);
        assertEq(nfts.length,1);
        assertEq(nfts[0].name,"CryptoPunk");
    }

    function testNonOwnerCannotViewUserNFTs() public{
        vm.startPrank(user1);
        vm.expectRevert(NFTVAULT_UNAUTHORIZEDACCESS.selector);
        nftVault.getUserNFTs(user2);
        vm.stopPrank();
    }

    function testOwnerCanDeleteUserNFT() public{
        vm.prank(user1);
        nftVault.storeNFT("CryptoPunk","Rare NFT","url",1,address(100));
        nftVault.deleteUserNFT(user1,0);
        assertEq(nftVault.getUserTotalNfts(user1),0);
    }

    function testNonOwnerCannotDeleteUserNFT() public{
        vm.startPrank(user1);
        nftVault.storeNFT("CryptoPunk","Rare NFT","url",1,address(100));
        vm.expectRevert(NFTVAULT_UNAUTHORIZEDACCESS.selector);
        nftVault.deleteUserNFT(user1,0);
        vm.stopPrank();
    }

    function testDeleteUserNFTInvalidIndex() public{
        vm.expectRevert(NFTVAULT_INVALIDINDEX.selector);
        nftVault.deleteUserNFT(user1,0);
    }

    function testUserNFTCount() public{
        vm.startPrank(user1);
        nftVault.storeNFT("NFT1","Desc","url",1,address(100));
        nftVault.storeNFT("NFT2","Desc","url",2,address(200));
        vm.stopPrank();
        assertEq(nftVault.getUserTotalNfts(user1),2);
    }
}