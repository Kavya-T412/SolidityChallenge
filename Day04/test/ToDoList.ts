import { expect } from "chai";
import { network } from "hardhat";


const { ethers } = await network.create();

describe("TodDoList Contract Testing", function(){
    let toDoList: any;
    let owner: any;
    let user1: any;
    let user2: any;

    beforeEach(async function(){
        [owner, user1, user2] = await ethers.getSigners();
        const ToDoListFactory = await ethers.getContractFactory("ToDoList");
        toDoList = await ToDoListFactory.deploy();
        await toDoList.waitForDeployment();
    });

    describe("Deployment", function(){
        it("Should deploy with a valid address", async function(){
            expect(await toDoList.getAddress()).to.not.equal(ethers.ZeroAddress);
        });
    });

    describe("Task Management", function(){
        it("Should add task successfully", async function(){
            await toDoList.connect(user1).addTask("Buy Groceries");
            const tasks = await toDoList.connect(user1).getMyTask();
            expect(tasks.length).to.equal(1);
            expect(tasks[0].title).to.equal("Buy Groceries");
            expect(tasks[0].completed).to.be.false;
        });

        it("Should revert when empty adding empty task", async function(){
            await expect(toDoList.connect(user1).addTask(""))
                    .to.be.revertedWithCustomError(toDoList, "EMPTYTASK");
        });

        it("Should mark task as completed", async function(){
            await toDoList.connect(user1).addTask("Buy Groceries");
            await toDoList.connect(user1).markAsDone(0);
            const tasks = await toDoList.connect(user1).getMyTask();
            expect(tasks[0].completed).to.be.true;
        });

        it("Should update task", async function(){
            await toDoList.connect(user1).addTask("Buy Groceries");
            await toDoList.connect(user1).updateTask(0, "Buy vegetables");
            const tasks = await toDoList.connect(user1).getMyTask();
            expect(tasks[0].title).to.equal("Buy vegetables");
            expect(tasks[0].completed).to.be.false;
        });

        it("Should delete a specific task", async function(){
            await toDoList.connect(user1).addTask("Buy Groceries");
            await toDoList.connect(user1).addTask("Buy Vegetables");
            await toDoList.connect(user1).deleteTask(0);
            const tasks = await toDoList.connect(user1).getMyTask();
            expect(tasks.length).to.be.equal(2);
            expect(tasks[0].title).to.equal("");  
        });

        it("Should delete all tasks", async function(){
            await toDoList.connect(user1).addTask("Buy Groceries");
            await toDoList.connect(user1).addTask("Buy Vegetables");
            await toDoList.connect(user1).addTask("Buy Fruits");
            await toDoList.connect(user1).deleteAllTasks();
            const tasks = await toDoList.connect(user1).getMyTask();
            expect(tasks.length).to.be.equal(0);
        });

        it("Should return correct task count", async function(){
            await toDoList.connect(user1).addTask("Buy Groceries");
            await toDoList.connect(user1).addTask("Buy Vegetables");
            await toDoList.connect(user1).addTask("Buy Fruits");
            const count = await toDoList.connect(user1).getTaskCount();
            expect(count).to.be.equal(3);
        });
    });

    describe("Access Control - Owner Functions", function(){
        it("Should allow owner to view any user's tasks", async function(){
            await toDoList.connect(user1).addTask("Buy Groceries");
            await toDoList.connect(user2).addTask("Buy Vegetables");
            const user1Tasks = await toDoList.connect(owner).getAllTasks(user1.address);
            const user2Tasks = await toDoList.connect(owner).getAllTasks(user2.address);
            expect(user1Tasks.length).to.equal(1);
            expect(user1Tasks[0].title).to.equal("Buy Groceries");
            expect(user2Tasks.length).to.equal(1);
            expect(user2Tasks[0].title).to.equal("Buy Vegetables");
        });

        it("Should NOT allow non-owner to view all tasks", async function(){
            await expect(toDoList.connect(user2).getAllTasks(user2.address))
                        .to.be.revertedWith("Unauthorised Access");
        });

    });

    describe("Multiple users", function(){
        it("Users should have isolated task lists", async function(){
            await toDoList.connect(user1).addTask("Buy Groceries");
            await toDoList.connect(user1).addTask("Buy Fruits");
            await toDoList.connect(user2).addTask("Buy Vegetables");
            await toDoList.connect(user2).addTask("Buy Dairy");
            await toDoList.connect(user2).addTask("Buy Meat");
            const user1Tasks = await toDoList.connect(user1).getMyTask();
            const user2Tasks = await toDoList.connect(user2).getMyTask();
            expect(user1Tasks.length).to.equal(2);
            expect(user1Tasks[0].title).to.equal("Buy Groceries");
            expect(user1Tasks[1].title).to.equal("Buy Fruits");
            expect(user2Tasks.length).to.equal(3);
            expect(user2Tasks[0].title).to.equal("Buy Vegetables");
            expect(user2Tasks[1].title).to.equal("Buy Dairy");
            expect(user2Tasks[2].title).to.equal("Buy Meat");
        });

    });

});