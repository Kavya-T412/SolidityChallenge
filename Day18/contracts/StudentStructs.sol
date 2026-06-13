// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// StudentStruct contract for StudentRecordSystem 

import {StudentTypes} from "./StudentTypes.sol";

library StudentStruct{

    // Groups student info
    struct StudentInput{
        string fName;
        string mName;
        string lName;
        uint256 dateOfBirth;
        StudentTypes.StudentGender studentGender;
        StudentTypes.StudentStatus studentStatus;
        string dept;
        string course;
        string location;
        uint256 mobileNumber;
        address studentAddress;
        string email;
        uint256 timestamp;
    }

    // Groups student's scores and grades
    struct StudentRecord{
        uint256[] courseScores;
        StudentTypes.Grade[] courseGrades;
        uint256[] performanceScores;
        StudentTypes.Grade[] performanceGrades;
        uint256[] attendanceScores;
        StudentTypes.Grade[] attendanceGrades;
    }

    // Groups updated student info
    struct UpdateStudentInput{
        string newFName;
        string newMName;
        string newLName;
        uint256 newDateOfBirth;
        string newDept;
        string newCourse;
        string newLocation;
        uint256 newMobileNumber;
        string newEmail;
        address newStudentAddress;
    }
}