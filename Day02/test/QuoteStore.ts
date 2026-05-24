import { expect } from "chai";
import { network } from "hardhat";

const { ethers } = await network.create();

describe("Testing QuoteStore Contract", function (){

    let quoteStore: any;
    let owner: any;
    let user1: any;
    let user2: any;
    
    beforeEach(async function (){
        [owner, user1, user2] = await ethers.getSigners();
        quoteStore = await ethers.deployContract("QuoteStore");
        await quoteStore.waitForDeployment();
    });
    
    //deployment test
    it("1. Should deploy the contract successfully", async function(){
        expect(await quoteStore.getAddress()).to.not.equal(ethers.ZeroAddress);
    });

    //store and retrieve quote test
    it("2. Should allow user to store and retrieve quote correctly", async function(){
        await quoteStore.connect(user1).storeQuote("Abdul Kalam","Dream big");
        const res = await quoteStore.connect(user1).myQuote();
        expect(res[0]).to.equal("Abdul Kalam");
        expect(res[1]).to.equal("Dream big");
    });

    //update quote test
    it("3. Should allow user to update quote correctly", async function(){
        await quoteStore.connect(user1).storeQuote("Abdul Kalam","Dream big");
        await quoteStore.connect(user1).updateQuote("APJ Abdul Kalam","Dream big, work hard");
        const updatedQuote = await quoteStore.connect(user1).myQuote();
        expect(updatedQuote.author).to.equal("APJ Abdul Kalam");
        expect(updatedQuote.description).to.equal("Dream big, work hard");
    });

    //delete quote test
    it("4. Should delete the user quote correctly", async function(){
        await quoteStore.connect(user1).storeQuote("Abdul Kalam","Dream big");
        await quoteStore.connect(user1).deleteQuote();
        const deletedQuote = await quoteStore.connect(user1).myQuote();
        expect(deletedQuote.author).to.equal("");
        expect(deletedQuote.description).to.equal("");
        expect(deletedQuote.timestamp).to.equal(0);
    });

    //allow to view other user's quote test
    it("5. Should allow viewing other user's quote correctly", async function(){
        await quoteStore.connect(user1).storeQuote("Abdul Kalam","Dream big");
        const result = await quoteStore.connect(user2).viewQuote(user1.address);
        expect(result.author).to.equal("Abdul Kalam");
        expect(result.description).to.equal("Dream big");
    });

    //retrive timestamp test
    it("6. Should return correct timestamp", async function(){
        await quoteStore.connect(user1).storeQuote("Abdul Kalam","Dream big");
        const block = await ethers.provider.getBlock("latest");
        const timestamp = await quoteStore.retriveTimestamp(user1.address);
        expect(timestamp).to.equal(block?.timestamp);
    });

    //allow multiple users to store and retrieve their quotes test
    it("7. Should store and retrieve different quotes for different users", async function(){
        await quoteStore.connect(user1).storeQuote("Albert Einstein","Imagination is more important than knowledge");
        await quoteStore.connect(user2).storeQuote("Isaac Newton","If I have seen further it is by standing on the shoulders of Giants");
        const quote1 = await quoteStore.viewQuote(user1.address);
        const quote2 = await quoteStore.viewQuote(user2.address);
        expect (quote1.author).to.equal("Albert Einstein");
        expect (quote1.description).to.equal("Imagination is more important than knowledge");
        expect (quote2.author).to.equal("Isaac Newton");
        expect (quote2.description).to.equal("If I have seen further it is by standing on the shoulders of Giants");
    });

    // Edge case testing
    it("8. Should owerwrite the quote if same user stores quote again", async function(){
        await quoteStore.connect(user1).storeQuote("Abdul Kalam","Dream big");
        await quoteStore.connect(user1).storeQuote("APJ Abdul Kalam","Dream big, work hard");
        const quote = await quoteStore.connect(user1).myQuote();
        expect(quote.author).to.equal("APJ Abdul Kalam");
        expect(quote.description).to.equal("Dream big, work hard");
    });

    it("9. Should return empty values for non-existent user quote", async function(){
        const quote = await quoteStore.connect(user2).myQuote();
        expect(quote.author).to.equal("");
        expect(quote.description).to.equal("");
        expect(quote.timestamp).to.equal(0);
    });


});