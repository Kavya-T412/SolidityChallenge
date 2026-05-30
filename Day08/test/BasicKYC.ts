import { expect } from "chai";
import { network } from "hardhat";

const { ethers } = await network.create();

describe("BasicKYC Contract Testing", function(){
    let basicKYC: any;
    let owner: any;
    let user1: any;
    let user2: any;

    beforeEach(async function(){
        [owner, user1, user2] = await ethers.getSigners();
        basicKYC = await ethers.deployContract("BasicKYC");
        await basicKYC.waitForDeployment();
    });

    describe("Deployment Test", async function(){
        it("Should deploy contract correctly", async function(){
            expect(await basicKYC.getOwner()).to.equal(owner.address);
        });
    });

    describe("User Registration Tests", async function(){
        it("Allow user to register", async function(){
            await basicKYC.connect(user1).register("Lavanya","Gowri",user1.address);
            const userData = await basicKYC.connect(user1).getMyDetails();
            expect(userData[0]).to.equal("Lavanya");
            expect(userData[1]).to.equal("Gowri");
            expect(userData[2]).to.equal(user1.address);
        });

        it("Should emit newUserRegistered event", async function(){
            await expect(basicKYC.connect(user1).register("Lavanya","Gowri",user1.address))
                        .to.emit(basicKYC, "newUserRegistered").withArgs("Lavanya",user1.address);
        });

        it("Should revert if existing user tries to register again", async function(){
            await basicKYC.connect(user1).register("Lavanya","Gowri",user1.address);
            await expect(basicKYC.connect(user1).register("Lavanya","Gowri",user1.address))
                        .to.be.revertedWithCustomError(basicKYC, "BASICKYC_EXISTINGUSER");
        });
    });

    describe("User Details Update Tests", async function(){
        it("Allow owner to get user details", async function(){
            await basicKYC.connect(user1).register("Lavanya","Gowri",user1.address);
            const userData = await basicKYC.connect(owner).getUserDetail(user1.address);
            expect(userData[0]).to.equal("Lavanya");
            expect(userData[1]).to.equal("Gowri");
        });

        it("Should revert if non-owner tries to get user details", async function(){
            await basicKYC.connect(user1).register("Lavanya","Gowri",user1.address);
            await expect(basicKYC.connect(user2).getUserDetail(user1.address))
                        .to.be.revertedWithCustomError(basicKYC, "BASICKYC_UNAUTHORIZEDACCESS");
        });
    });

    describe("Verification Tests", async function() {
        it("Allow owner to verify user", async function(){
            await basicKYC.connect(user1).register("Lavanya","Gowri",user1.address);
            await basicKYC.connect(owner).markAsVerified(user1.address);
            expect (await basicKYC.checkIfUserIsVerified(user1.address)).to.equal(true);
        });

        it("Should emit newAddressVerified event", async function(){
            await basicKYC.connect(user1).register("Lavanya","Gowri",user1.address);
            await expect(basicKYC.connect(owner).markAsVerified(user1.address))
                        .to.emit(basicKYC, "newAddressVerified").withArgs(user1.address);
        });

        it("Should revert if user is already verified", async function (){
            await basicKYC.connect(user1).register("Lavanya","Gowri",user1.address);
            await basicKYC.connect(owner).markAsVerified(user1.address);
            await expect(basicKYC.connect(owner).markAsVerified(user1.address))
                    .to.be.revertedWithCustomError(basicKYC,"BASICKYC_USERISVERIFIED");
        });

        it("Allow owner to remove verification", async function(){
            await basicKYC.connect(user1).register("Lavanya","Gowri",user1.address);
            await basicKYC.connect(owner).markAsVerified(user1.address);
            await basicKYC.connect(owner).removeUserVerification(user1.address);
            expect (await basicKYC.checkIfUserIsVerified(user1.address)).to.equal(false);
        });

        it("Revert if removing verification from non-verified user", async function(){
            await expect(basicKYC.connect(owner).removeUserVerification(user1.address))
                        .to.be.revertedWithCustomError(basicKYC,"BASICKYC_USERISNOTVERIFIED");
        });

    });

    describe("Delete User Tests", async function(){
        it("Allow owner to delete user", async function(){
            await basicKYC.connect(user1).register("Lavanya","Gowri",user1.address);
            await basicKYC.connect(owner).deleteUser(user1.address);
            const userData = await basicKYC.connect(user1).getMyDetails();
            expect(userData[0]).to.equal("");
        });

        it("Should emit userDeleted event", async function(){
            await basicKYC.connect(user1).register("Lavanya","Gowri",user1.address);
            await expect(basicKYC.connect(owner).deleteUser(user1.address))
                    .to.emit(basicKYC, "userDeleted").withArgs(user1.address);
        });

        it("Allow user to delete their own account", async function(){
            await basicKYC.connect(user1).register("Lavanya","Gowri",user1.address);
            await basicKYC.connect(user1).deleteMyData();
            const userData = await basicKYC.connect(user1).getMyDetails();
            expect(userData[0]).to.equal("");
        });
    });
});
