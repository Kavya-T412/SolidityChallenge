import { expect } from "chai";
import { network } from "hardhat";

const { ethers } = await network.create();

describe("VotingSystem Contract Testing", function () {

    let votingSystem: any;

    let owner: any;
    let voter1: any;
    let voter2: any;

    beforeEach(async function () {
        [owner, voter1, voter2] = await ethers.getSigners();
        votingSystem = await ethers.deployContract("VotingSystem");
        await votingSystem.waitForDeployment();
    });

    it("Should deploy contract correctly", async function () {
        expect(await votingSystem.getOwner()).to.equal(owner.address);
    });

    it("Should allow owner to create proposal", async function () {
        await votingSystem.connect(owner).createAProposal("Proposal 1","Description 1",1);
        const proposal = await votingSystem.getProposalData(1);
        expect(proposal[0]).to.equal("Proposal 1");
        expect(proposal[1]).to.equal("Description 1");
        expect(proposal[2]).to.equal(1);
    });

    it("Should emit proposal creation event", async function () {
        await expect(votingSystem.connect(owner).createAProposal("Proposal 1","Description 1",1))
                    .to.emit(votingSystem,"newProposalCreated").withArgs("Proposal 1", "Description 1", 1);
    });

    it("Should revert if non-owner creates proposal", async function () {
        await expect(votingSystem.connect(voter1).createAProposal("Proposal 1","Description",1))
                    .to.be.revertedWithCustomError(votingSystem,"VOTINGSYSTEM_UNAUTHORIZEDACCESS");
    });

    it("Should revert if proposal already exists", async function () {
        await votingSystem.connect(owner).createAProposal("Proposal 2","Description",2);
        await expect(votingSystem.connect(owner).createAProposal("Proposal 2","Description",2))
                    .to.be.revertedWithCustomError(votingSystem,"VOTINGSYSTEM_EXIXTINGPROPOSAL");
    });

    it("Should register voter", async function () {
        await votingSystem.connect(voter1).register( "John","Doe");
        expect(await votingSystem.totalVoters()).to.equal(1);
    });

    it("Should emit voter registration event", async function () {
        await expect(votingSystem.connect(voter1).register("John","Doe"))
                    .to.emit(votingSystem,"newRegistedVoter").withArgs("John","Doe",voter1.address);
    });

    it("Should revert if voter already exists", async function () {
        await votingSystem.connect(voter1).register("John","Doe");
        await expect(votingSystem.connect(voter1).register("John","Doe"))
                    .to.be.revertedWithCustomError(votingSystem,"VOTINGSYSTEM_EXISTINGVOTER");
    });

    it("Should allow registered voter to vote", async function () {
        await votingSystem.connect(owner).createAProposal("Proposal 1","Description",1);
        await votingSystem.connect(voter1).register("John","Doe");
        await votingSystem.connect(voter1).vote("Proposal 1","Description",1);
        expect(await votingSystem.connect(voter1).getMyStatus()).to.equal(true);
    });

    it("Should emit vote event", async function () {
        await votingSystem.connect(owner).createAProposal("Proposal 1","Description",1);
        await votingSystem.connect(voter1).register("John","Doe");
        await expect(votingSystem.connect(voter1).vote("Proposal 1","Description",1))
                .to.emit(votingSystem,"userHasVoted").withArgs(voter1.address);
    });

    it("Should revert if voter votes twice", async function () {
        await votingSystem.connect(owner).createAProposal("Proposal 1","Description",1);
        await votingSystem.connect(voter1).register("John","Doe");
        await votingSystem.connect(voter1).vote("Proposal 1","Description",1);
        await expect(votingSystem.connect(voter1).vote("Proposal 1","Description",1))
                .to.be.revertedWithCustomError(votingSystem,"VOTINGSYSTEM_VOTERALREADYVOTED");
    });

    it("Should revert if non-registered voter votes", async function () {
        await votingSystem.connect(owner).createAProposal("Proposal 1","Description",1);
        await expect(votingSystem.connect(voter1).vote("Proposal 1","Description",1))
                .to.be.revertedWithCustomError( votingSystem,"VOTINGSYSTEM_NOTANEXISTINGVOTER");
    });

    it("Owner should check voter status", async function () {
        await votingSystem.connect(owner).createAProposal("Proposal 1","Description",1);
        await votingSystem.connect(voter1).register("John","Doe");
        await votingSystem.connect(voter1).vote("Proposal 1","Description",1);
        expect(await votingSystem.connect(owner).getVoterStatus(voter1.address)).to.equal(true);
    });

    it("Should revert when non-owner checks voter status", async function () {
        await expect(votingSystem.connect(voter1).getVoterStatus(voter2.address))
                .to.be.revertedWithCustomError(votingSystem,"VOTINGSYSTEM_UNAUTHORIZEDACCESS");
    });

});