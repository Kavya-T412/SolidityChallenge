import { expect } from "chai";
import { network } from "hardhat";

const { ethers } = await network.create();

describe("DonationVault Contract Testing", function(){
    let donationVault: any;
    let owner: any;
    let user1: any;
    let user2: any;

    beforeEach(async function(){
        [owner, user1, user2] = await ethers.getSigners();
        donationVault = await ethers.deployContract("DonationVault");
        await donationVault.waitForDeployment();
    });

    it("Should deploy the contract correctly", async function(){
        expect(await donationVault.getOwner()).to.equal(owner.address);
    });

    describe("Deposit Tests", function(){
        it("Allow users to deposit ETH", async function(){
            const depositAmount = ethers.parseEther("1");
            await donationVault.connect(user1). depositETH({value: depositAmount});
            expect (await donationVault.connect(user1).getMyDepositHistory())
                    .to.equal(depositAmount);
        });

        it("Should emit Deposit event on successful deposit", async function(){
            const depositAmt = ethers.parseEther("0.5");
            await expect(donationVault.connect(user1).depositETH({value: depositAmt}))
                        .to.emit(donationVault, "newDeposit").withArgs(depositAmt, user1.address);
        });

        it("Should revert if deposit amount is zero", async function(){
            await expect(donationVault.connect(user1).depositETH({value: 0}))
                        .to.be.revertedWithCustomError(donationVault, "DONATIONVAULT_ETHAMOUNTISTOOLOW");
        });
    });

    describe("Withdrawal Tests", function(){
        it("Allow owner to withdraw ETH", async function(){
            const depositAmt = ethers.parseEther("1");
            await donationVault.connect(user1).depositETH({value: depositAmt});
            expect(await ethers.provider.getBalance(await donationVault.getAddress())).to.equal(depositAmt);
            await donationVault.connect(owner).withdrawAll();
            expect(await ethers.provider.getBalance(await donationVault.getAddress())).to.equal(0);
            
        });

        it("Should emit ownerWithdrewAll event", async function(){
            const depositAmt = ethers.parseEther("1");
            await donationVault.connect(user1).depositETH({value: depositAmt});
            await expect(donationVault.connect(owner).withdrawAll())
                        .to.emit(donationVault, "ownerWithdrewAll").withArgs(depositAmt, owner.address);
        });

        it("Should revert if non-owner tries to withdraw", async function(){
            await expect(donationVault.connect(user1).withdrawAll())
                        .to.be.revertedWithCustomError(donationVault, "DONATIONVAULT_UNAUTHORIZED_ACCESS");
        });

        it("Should revert if owner tries to withdraw with zero balance", async function(){
            await expect(donationVault.connect(owner).withdrawAll())
                        .to.be.revertedWithCustomError(donationVault, "DONATIONVAULT_INSUFFECIENTBALANCE");
        });
    });

    describe("Access control tests", function(){
        it("Alllow only owner to access getTotalDeposit()", async function(){
            await expect( donationVault.connect(user1).getTotalDeposit())
                        .to.be.revertedWithCustomError(donationVault, "DONATIONVAULT_UNAUTHORIZED_ACCESS");
        });
    });
});