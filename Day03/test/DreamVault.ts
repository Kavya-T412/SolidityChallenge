import { expect } from "chai";
import { network } from "hardhat";

const { ethers } = await network.create();

describe("DreamVault contract test", function(){

    let dreamVault: any;
    let owner: any;
    let user1: any;
    let user2: any;

    beforeEach(async function(){
        [owner, user1, user2] = await ethers.getSigners();
        dreamVault = await ethers.deployContract("DreamVault");
        await dreamVault.waitForDeployment();
    });

    it("Should deploy contract correctly", async function(){
        expect(await dreamVault.getAddress()).to.not.equal(ethers.ZeroAddress);
    });

    it("Should allow user to store and retrieve a dream", async function(){
        await dreamVault.connect(user1).storeDream("My Dream", "I want to be a blockchain developer!");
        const dream = await dreamVault.connect(user1).viewMyDream();
        expect(dream[0]).to.equal("My Dream");
        expect(dream[1]).to.equal("I want to be a blockchain developer!");
    });

    it("Should allow user to update their dreams", async function(){
        await dreamVault.connect(user1).storeDream("Dream 1", "First dream");
        await dreamVault.connect(user1).updateDream("Updated Dream", "Updated dream description");
        const dream = await dreamVault.connect(user1).viewMyDream();
        expect(dream[0]).to.equal("Updated Dream");
        expect(dream[1]).to.equal("Updated dream description");
    });

    it("Should allow user to delete their dreams", async function(){
        await dreamVault.connect(user1).storeDream("Dream 1", "First dream");
        await dreamVault.connect(user1).deleteDream();
        const dream = await dreamVault.connect(user1).viewMyDream();
        expect(dream[0]).to.equal("");
        expect(dream[1]).to.equal("");
    }); 

    it("Should allow owner to view all user's dreams using user's address", async function(){
        await dreamVault.connect(user1).storeDream("Dream 1", "First dream");
        const dreams = await dreamVault.connect(owner).viewAllDreams(user1.address);
        expect(dreams[0]).to.equal("Dream 1");
        expect(dreams[1]).to.equal("First dream");
    });

    it("Non-owner should not be able to view other user's dreams", async function(){
        await dreamVault.connect(user1).storeDream("Dream 1", "First dream");
        await expect(dreamVault.connect(user2).viewAllDreams(user1.address))
                    .to.be.revertedWith("Only the owner can call this function");
    });

    it("Allow owner to get dremer's address by index", async function(){
        await dreamVault.connect(user1).storeDream("Dream 1", "First dream");
        const dremerAddress = await dreamVault.connect(owner).getDremerAtIndex(0);
        expect(dremerAddress).to.equal(user1.address);
    });

    it("Non-owner should not be able to get dremer's address by index", async function(){
        await dreamVault.connect(user1).storeDream("Dream 1", "First dream");
        await expect(dreamVault.connect(user2).getDremerAtIndex(0))
                    .to.be.revertedWith("Only the owner can call this function");
    });

    it("Allow owner to get all dreamer's addresses", async function(){
        await dreamVault.connect(user1).storeDream("Dream 1", "First dream");
        await dreamVault.connect(user2).storeDream("Dream 2", "Second dream");
        const dreamers = await dreamVault.connect(owner).getAllDreamers();
        expect(dreamers.length).to.equal(2);
        expect(dreamers[0]).to.equal(user1.address);
        expect(dreamers[1]).to.equal(user2.address);
    });

    it("Non-owner should not be able to get all dreamer's addresses", async function(){
        await dreamVault.connect(user1).storeDream("Dream 1", "First dream");
        await dreamVault.connect(user2).storeDream("Dream 2", "Second dream");
        await expect(dreamVault.connect(user2).getAllDreamers())
                    .to.be.revertedWith("Only the owner can call this function");
    });

});