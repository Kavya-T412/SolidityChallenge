// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import{Utils} from "./Utils.sol";
import {StudentLib} from "./StudentLib.sol";
import {StudentTypes} from "./StudentTypes.sol";
import {StudentStruct} from "./StudentStructs.sol";

error STUDENTRECORDSYSTEM_STUDENT_DOESNT_EXIST(uint256 studentId);
error STUDENTRECORDSYSTEM_EXISTING_STUDENT_ADDRESS(address studentAddress);
error STUDENTRECORDSYSTEM_STUDENT_ADDRESS_DOESNT_EXIST(address studentAddress);

contract StudentRegistry is Utils{ // inheriting utils file

    using StudentLib for StudentLib.StudentStorage; // student storage struct used from studentLib
    uint256 public studentCount;

    // student storage struct variable, maps all four mappings in studentLib to one variable
    StudentLib.StudentStorage internal studentStore; 

    event StudentRegistered(uint256 indexed studentId, string fName, string lName, string dept, string course, address indexed studentAddress);
    event StudentBioUpdated(uint256 indexed studentId, string newFName, string newLName);
    event StudentContactUpdated(uint256 indexed studentId, string newDept, string newCourse, address indexed studentNewAddress);
    event StudentDeleted(uint256 indexed studentId, address studentAddress);

    // Registers student data to the contract
    function register(StudentStruct.StudentInput memory input) internal isActive isRegistrar{
        if(studentStore.existingAddress[input.studentAddress] == true) revert STUDENTRECORDSYSTEM_EXISTING_STUDENT_ADDRESS(input.studentAddress);
        StudentLib.Student memory newStudent;
        studentCount++;
        uint256 studentId = studentCount;
        newStudent.fName = input.fName;
        newStudent.mName = input.mName;
        newStudent.lName = input.lName;
        newStudent.dateOfBirth = input.dateOfBirth;
        newStudent.dept = input.dept;
        newStudent.course = input.course;
        newStudent.location = input.location;
        newStudent.mobileNumber = input.mobileNumber;
        newStudent.studentAddress = input.studentAddress;
        newStudent.email = input.email;
        newStudent.timestamp = block.timestamp;

        studentStore.existingStudent[studentId] = true; // student id = true in existing student mapping
        studentStore.existingAddress[input.studentAddress] = true; // student address = true in existing address mapping
        studentStore.studentsByAddress[input.studentAddress] = newStudent; // stores student info to their address
        studentStore.students[studentId] = newStudent; // stores student info to their id

        emit StudentRegistered(studentId, input.fName, input.lName, input.dept, input.course, input.studentAddress);
    }

    // Updates student data stored in the contract
    function updateStudent(uint256 _studentId, StudentStruct.UpdateStudentInput memory input) internal isActive isRegistrar {
        if(!studentStore.existingStudent[_studentId]) revert STUDENTRECORDSYSTEM_STUDENT_DOESNT_EXIST(_studentId);
        StudentLib.Student storage student = studentStore.students[_studentId]; // gets student info stored to their id
        
        if(input.newStudentAddress != student.studentAddress){
            address oldStudentAddress = student.studentAddress;
            if(studentStore.existingAddress[input.newStudentAddress]) revert STUDENTRECORDSYSTEM_EXISTING_STUDENT_ADDRESS(input.newStudentAddress);
            delete studentStore.studentsByAddress[oldStudentAddress];
            student.studentAddress = input.newStudentAddress; // updates student address in student info

            student.fName = input.newFName;
            student.mName = input.newMName;
            student.lName = input.newLName;
            student.dateOfBirth = input.newDateOfBirth;
            student.dept = input.newDept;
            student.course = input.newCourse;
            student.location = input.newLocation;
            student.mobileNumber = input.newMobileNumber;
            student.email = input.newEmail;

            studentStore.studentsByAddress[input.newStudentAddress] = student; // updates student info to their new address
            studentStore.existingAddress[oldStudentAddress] = false; // old student address = false in existing address mapping
            studentStore.existingAddress[input.newStudentAddress] = true; // new student address = true in existing address mapping

            emit StudentBioUpdated(_studentId, input.newFName, input.newLName);
            emit StudentContactUpdated(_studentId, input.newDept, input.newCourse, input.newStudentAddress);

        } 
    }

    // Deletes student data stored in the contract
    function deleteStudentData(uint256 _studentId, address _studentAddress) internal isActive isRegistrar {
        if(studentStore.existingStudent[_studentId] != true) revert STUDENTRECORDSYSTEM_STUDENT_DOESNT_EXIST(_studentId);
        if(studentStore.existingAddress[_studentAddress] != true) revert STUDENTRECORDSYSTEM_STUDENT_ADDRESS_DOESNT_EXIST(_studentAddress);
        delete studentStore.students[_studentId]; // deletes student info stored to their id
        delete studentStore.studentsByAddress[_studentAddress]; // deletes student info stored to their address
        studentStore.existingStudent[_studentId] = false; // student id = false in existing student mapping
        studentStore.existingAddress[_studentAddress] = false; // student address = false in existing address mapping

        emit StudentDeleted(_studentId, _studentAddress);
    }
}