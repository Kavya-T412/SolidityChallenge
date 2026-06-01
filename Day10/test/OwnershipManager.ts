import { expect } from "chai";
import { network } from "hardhat";

const { ethers } = await network.create();


describe("OwnershipManager Contract Testing", function () {
    let ownershipManager: any;
    let owner: any;
    let user1: any;
    let user2: any;

    beforeEach(async function () {
        [owner, user1, user2] = await ethers.getSigners();
        ownershipManager = await ethers.deployContract("OwnershipManager");
        await ownershipManager.waitForDeployment();
    });

    describe("Deployment Tests", function(){
        it("Should set the deployer as the owner", async function () {
            await ownershipManager.connect(owner).transferOwnership(user1.address);
            expect(await ownershipManager.getOwner()).to.equal(user1.address);
        });
    });

    describe("Ownership Transfer Tests", function(){
        it("Should transfer ownership", async function () {
            await ownershipManager.connect(owner).transferOwnership(user1.address);
            expect(await ownershipManager.getOwner()).to.equal(user1.address);
        });

        it("Should emit OwnershipTransferred event", async function () {
            await expect(ownershipManager.connect(owner).transferOwnership(user1.address))
                    .to.emit(ownershipManager,"OwnershipTransferred").withArgs(user1.address);
        });

        it("Should revert if non-owner transfers ownership", async function () {
            await expect(ownershipManager.connect(user1).transferOwnership(user2.address))
                        .to.be.revertedWithCustomError(ownershipManager,"UNAUTHORIZED_ACCESS");
        });

        it("Should revert if new owner is zero address", async function () {
            await expect(ownershipManager.connect(owner).transferOwnership(ethers.ZeroAddress))
                        .to.be.revertedWithCustomError(ownershipManager,"INVALID_ADDRESS");
        });
    });

    describe("Renounce Ownership Tests", function(){
        it("Should renounce ownership", async function () {
            await ownershipManager.connect(owner).renounceOwnership();
            expect(await ownershipManager.getOwner()).to.equal(ethers.ZeroAddress);
        });

        it("Should emit OwnershipRenounced event", async function () {
            await expect(ownershipManager.connect(owner).renounceOwnership())
                        .to.emit(ownershipManager,"OwnershipRenounced").withArgs(ethers.ZeroAddress);
        });

        it("Should revert if non-owner renounces ownership", async function () {
            await expect(ownershipManager.connect(user1).renounceOwnership())
                        .to.be.revertedWithCustomError(ownershipManager,"UNAUTHORIZED_ACCESS");
        }); 
    });

    describe("Owner Data Tests", function(){
        it("Should update owner data", async function () {
            await ownershipManager.connect(owner).changeOwnerData("John","Doe");
            const ownerData =await ownershipManager.getOwnerData();
            expect(ownerData[0]).to.equal("John");
            expect(ownerData[1]).to.equal("Doe");
            expect(ownerData[2]).to.equal(owner.address);
        });

        it("Should emit NewOwnerData event", async function () {
            await expect(ownershipManager.connect(owner).changeOwnerData("John","Doe"))
                    .to.emit(ownershipManager,"NewOwnerData").withArgs("John","Doe");
        })

        it("Should revert if non-owner updates data", async function () {
            await expect(ownershipManager.connect(user1).changeOwnerData("John","Doe"))
                .to.be.revertedWithCustomError(ownershipManager,"UNAUTHORIZED_ACCESS");
        });

        it("Should return correct owner data", async function () {
            await ownershipManager.connect(owner).changeOwnerData("Alice","Smith");
            const ownerData =await ownershipManager.getOwnerData();
            expect(ownerData[0]).to.equal("Alice");
            expect(ownerData[1]).to.equal("Smith");
            expect(ownerData[2]).to.equal(owner.address);
            expect(ownerData[3]).to.be.gt(0);
        });

        it("Should return contract summary", async function () {
            await ownershipManager.connect(owner).changeOwnerData("Alice","Smith");
            const summary = await ownershipManager.getContractSummary();
            expect(summary[0]).to.equal("Alice");
            expect(summary[1]).to.equal("Smith");
            expect(summary[2]).to.equal(owner.address);
        });
    });

});