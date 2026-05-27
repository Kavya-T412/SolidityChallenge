import { expect } from "chai";
import { network } from "hardhat";

const { ethers } = await network.create();

describe("WhiteListApp Contract Testing", function(){

    let whitelistContract: any;
    let owner: any;
    let user1: any;
    let user2: any;

    beforeEach(async function(){
        [owner, user1, user2] = await ethers.getSigners();
        whitelistContract = await ethers.deployContract("WhiteListApp");
        await whitelistContract.waitForDeployment();
    });

    it("Should deploy the contract correctly", async function() {
        expect(await whitelistContract.getOwner()).to.equal(owner.address);
    });

    it("Should add users to the whitelist", async function() {
        await whitelistContract.connect(user1).joinWhitelist();
        expect(await whitelistContract.connect(user1).checkIfWhitelisted()).to.equal(true);
    });

    it("Should store user address in array", async function() {
        await whitelistContract.connect(user1).joinWhitelist();
        const users = await whitelistContract.getAllWhitelistedUsers();
        expect(users[0]).to.equal(user1.address);
    });

    it("Revert if existing user tries to join again", async function (){
        await whitelistContract.connect(user1).joinWhitelist();
        await expect(whitelistContract.connect(user1).joinWhitelist()).to.be.revertedWithCustomError(whitelistContract, "WHITELIST_EXISTING_USER");
    });

    it("Return true for whitelisted users", async function() {
        await whitelistContract.connect(user1).joinWhitelist();
        expect (await whitelistContract.checkIfUserIsWhitelisted(user1.address)).to.equal(true);
    });

    it("Return false for non-whitelisted users", async function() {
        expect (await whitelistContract.checkIfUserIsWhitelisted(user2.address)).to.equal(false);
    });

    it("Allow owner to delete whitelisted address", async function(){
        await whitelistContract.connect(user1).joinWhitelist();
        await whitelistContract.connect(owner).deleteAddress(user1.address);
        expect(await whitelistContract.checkIfUserIsWhitelisted(user1.address)).to.equal(false);
    });

    it("Revert if non-owner tries to delete address", async function(){
        await expect(whitelistContract.connect(user2).deleteAddress(user1.address))
                    .to.be.revertedWithCustomError(whitelistContract, "WHITELIST_UNAUTHORIZED_ACCESS");
    });
        
    

    
});