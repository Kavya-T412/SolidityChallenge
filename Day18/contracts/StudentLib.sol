// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// Library for StudentRecordSystem

error STUDENTRECORDSYSTEM_STUDENT_DOESNT_EXIST();
error STUDENTRECORDSYSTEM_EXISTING_STUDENT_ADDRESS();

import {StudentTypes} from "./StudentTypes.sol";

library StudentLib{

    // Groups Student info
    struct Student {
        string fName;
        string mName;
        string lName;
        uint256 dateOfBirth;
        uint8 studentGender;
        uint8 studentStatus;
        string dept;
        string course;
        string location;
        uint256 mobileNumber;
        address studentAddress;
        string email;
        uint256 timestamp;
    }

    // Groups student records
    struct StudentRecord {
        uint256[] courseScores;
        StudentTypes.Grade[] courseGrades;
        uint256[] performanceScores;
        StudentTypes.Grade[] performanceGrades;
        uint256[] attendanceScores;
        StudentTypes.Grade[] attendanceGrades;
        uint256 timestamp;
    }

    // Groups mapping for student data, records and validation
    struct StudentStorage {
        mapping(uint256 => Student) students; // studentId => Student personal info
        mapping(uint256 => StudentRecord) studentRecords; // studentId => Student academic records
        mapping(address => StudentRecord) studentRecordByAddress; // studentAddress => Student academic records
        mapping(address => Student) studentsByAddress; // studentAddress => Student personal info
        mapping(uint256 => bool) existingStudent; // tracks existance of student by Id
        mapping(address => bool) existingAddress; // tracks existance of student by address
    }

    // Returns student's data
    function getStudent(StudentStorage storage student, uint256 _studentId) internal view returns(Student memory){
        if(!student.existingStudent[_studentId]) revert STUDENTRECORDSYSTEM_STUDENT_DOESNT_EXIST();
        return student.students[_studentId];
    }

    // Checks the existance of student by id
    function exist(StudentStorage storage student, uint256 _studentId) internal view returns(bool){
        return student.existingStudent[_studentId];
    }

    // Checks the existance of student by address
    function existAddress(StudentStorage storage student, address _studentAddress) internal view returns(bool){
        return student.existingAddress[_studentAddress];
    }
}