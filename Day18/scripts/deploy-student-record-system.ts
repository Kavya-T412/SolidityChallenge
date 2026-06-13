import { network } from "hardhat";

const { ethers } = await network.create();

const studentRecordSystem = await ethers.deployContract("StudentRecordSystem");
await studentRecordSystem.waitForDeployment();

console.log("StudentRecordSystem deployed to:", await studentRecordSystem.getAddress());

await studentRecordSystem.activateContract();
console.log("Contract state:", await studentRecordSystem.isContractActive());

const studentInput = {
  fName: "Ada",
  mName: "Grace",
  lName: "Lovelace",
  dateOfBirth: 20000101n,
  studentGender: 1,
  studentStatus: 0,
  dept: "Computer Science",
  course: "Solidity 101",
  location: "Lagos",
  mobileNumber: 2348012345678n,
  studentAddress: ethers.ZeroAddress,
  email: "ada@example.com",
  timestamp: 0n,
};

const [deployer] = await ethers.getSigners();
const registeredStudent = {
  ...studentInput,
  studentAddress: deployer.address,
};

await studentRecordSystem.registerStudent(registeredStudent);
console.log("Registered student count:", await studentRecordSystem.studentCount());

const scores = [90n, 85n, 92n];
await studentRecordSystem.addStudentCourseScores(1n, scores);
console.log("Course scores:", await studentRecordSystem.getStudentCourseScores(1n));

const grades = [0, 2];
await studentRecordSystem.addStudentGrades(1n, grades, grades, grades);
console.log("Course grades:", await studentRecordSystem.getStudentCourseGrades(1n));

console.log("Deployment and execution complete.");