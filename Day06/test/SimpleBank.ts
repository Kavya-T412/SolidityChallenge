import { expect } from "chai";
import { network } from "hardhat";

const { ethers } = await network.create();

describe("SimpleBank Contract Testing", function(){
    let simpleBank: any;
    let owner: any;
    let user1: any;
    let user2: any;

    beforeEach(async function(){
        [owner, user1, user2] = await ethers.getSigners();
        simpleBank = await ethers.deployContract("SimpleBank");
        await simpleBank.waitForDeployment();
    });

    it("Should deploy contract correctly", async function(){
        expect(await simpleBank.getOwner()).to.equal(owner.address);
    });

    describe("Deposit Tests", function(){
        it("Allow users to deposit ETH", async function(){
            const depositAmount = ethers.parseEther("1");
            await simpleBank.connect(user1).depositETH({value: depositAmount});
            expect(await simpleBank.connect(user1).getMyBalance()).to.equal(depositAmount);
        });

        it("Should emit ethDeposited Event", async function(){
            const depositAmt = ethers.parseEther("1");
            await expect(simpleBank.connect(user1).depositETH({value: depositAmt}))
                    .to.emit(simpleBank, "ethDeposited").withArgs(user1.address, depositAmt);
        });

        it("Revert if deposit amount is 0", async function(){
            await expect(simpleBank.connect(user1).depositETH({value: 0}))
                    .to.be.revertedWithCustomError(simpleBank, "SIMPLEBANK_ETHAMOUNTISTOOLOW");
        });
    });

    describe("Withdraw Tests", function(){
        it("Allow users to withdraw ETH", async function(){
            const depositAmt = ethers.parseEther("1");
            const withdrawAmt = ethers.parseEther("0.5");
            await simpleBank.connect(user1).depositETH({value: depositAmt});
            await simpleBank.connect(user1).withdrawETH(withdrawAmt);
            expect(await simpleBank.connect(user1).getMyBalance())
                .to.equal(ethers.parseEther("0.5"));
        });

        it("Emit ethWithdrawn Event", async function(){
            const depositAmt = ethers.parseEther("1");
            const withdrawAmt = ethers.parseEther("0.5");
            await simpleBank.connect(user1).depositETH({value: depositAmt});
            await expect(simpleBank.connect(user1).withdrawETH(withdrawAmt))
                    .to.emit(simpleBank, "ethWithdrawn").withArgs(user1.address, withdrawAmt);
        });

        it("Revert if user withdraws more than balance", async function(){
            const depositAmt = ethers.parseEther("1");
            const withdrawAmt = ethers.parseEther("1.5");
            await simpleBank.connect(user1).depositETH({value: depositAmt});
            await expect(simpleBank.connect(user1).withdrawETH(withdrawAmt))
                    .to.be.revertedWithCustomError(simpleBank, "SIMPLEBANK_INSUFFICIENTBALANCE");
        });
    });

    describe("Balance Tests", function(){
        it("Should return correct user balance", async function(){
            const depositAmt = ethers.parseEther("1");
            await simpleBank.connect(user1).depositETH({value: depositAmt});
            expect(await simpleBank.connect(user1).getMyBalance()).to.equal(depositAmt);
        });

        it("Should allow owner to check Bank balance", async function(){
            const depositAmt1 = ethers.parseEther("1");
            const depositAmt2 = ethers.parseEther("2");
            await simpleBank.connect(user1).depositETH({value: depositAmt1});
            await simpleBank.connect(user2).depositETH({value: depositAmt2});
            expect(await simpleBank.getBankBalance()).to.equal(ethers.parseEther("3"));
        });

        it("Should revert if non-user tries to check Bank balance", async function(){
            await expect(simpleBank.connect(user1).getBankBalance())
                    .to.be.revertedWithCustomError(simpleBank, "SIMPLEBANK_UNAUTHORIZED_ACCESS");
        });

        it("Allow owner to check any users balance", async function(){
            const depositAmt = ethers.parseEther("1");
            await simpleBank.connect(user1).depositETH({value: depositAmt});
            expect(await simpleBank.getUserBalance(user1.address)).to.equal(depositAmt);
        });

        it("Should revert if non-owner tries to check other users balance", async function(){
            await expect(simpleBank.connect(user1).getUserBalance(user2.address))
                    .to.be.revertedWithCustomError(simpleBank, "SIMPLEBANK_UNAUTHORIZED_ACCESS");
        });
    });

    describe("Ownership Tests", function(){
        it("Should transfer ownership correctly", async function(){
            await simpleBank.connect(owner).transferOwnership(user1.address);
            expect(await simpleBank.getOwner()).to.equal(user1.address);
        });

        it("Should revert if non-owner transfers ownership", async function(){
            await expect(simpleBank.connect(user1).transferOwnership(user2.address))
                    .to.be.revertedWithCustomError(simpleBank, "SIMPLEBANK_UNAUTHORIZED_ACCESS");
        });
    });

});