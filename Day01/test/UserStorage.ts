import {expect} from "chai";
import {network} from "hardhat";

describe ("UserStorage Contract", function(){
    let userStorage: any;
    let owner: any;
    let user1: any;
    let user2: any;

    beforeEach(async function (){
        const connection = await network.create();
        const {ethers} = connection;
        [owner, user1, user2] = await ethers.getSigners();
        userStorage = await ethers.deployContract("UserStorage");
        await userStorage.waitForDeployment();
    });

    //deployment test
    it("Should deploy the contract successfully", async function(){
        const connection = await network.create();
        const {ethers} = connection;
        expect(await userStorage.getAddress()).to.not.equal(ethers.ZeroAddress);
    });

    //store and retrieve user details test
    describe("store function and retrieve function", function(){
        it("Should store user details correctly", async function(){
            await userStorage.connect(user1).store("Mitra",20);
            const res = await userStorage.getDetails(user1.address);
            expect(res[0]).to.equal("Mitra");
            expect(res[1]).to.equal(20);
        });
    });

    //update user details test
    describe("Update details function", function(){
        it("Should update user details correctly", async function(){
            await userStorage.connect(user1).store("Mitra",20);
            await userStorage.connect(user1).updateDetails("Aishu",25);
            const [name, age] = await userStorage.getDetails(user1.address);
            expect(name).to.equal("Aishu");
            expect(age).to.equal(25);
        });
    });

    //delete user details test
    describe("Delete details function", function (){
        it("Should delete user details correctly", async function(){
            await userStorage.connect(user1).store("Mitra",20);
            await userStorage.connect(user1).deleteDetails();
            const [name, age] = await userStorage.getDetails(user1.address);
            expect(name).to.equal("");
            expect(age).to.equal(0);
        });
    });


});