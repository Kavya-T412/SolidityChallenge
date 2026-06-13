// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import { Test } from "forge-std/Test.sol";

import { AcademicRecordManager } from "../contracts/AcademicRecordManager.sol";
import { GradesManager } from "../contracts/GradesManager.sol";
import { StudentLib } from "../contracts/StudentLib.sol";
import { StudentRecordSystem } from "../contracts/StudentRecordSystem.sol";
import { StudentRegistry } from "../contracts/StudentRegistry.sol";
import { StudentStruct } from "../contracts/StudentStructs.sol";
import { StudentTypes } from "../contracts/StudentTypes.sol";
import { Utils } from "../contracts/Utils.sol";

contract StudentRecordSystemTest is Test {
    StudentRecordSystem private system;

    address private constant OUTSIDER = address(0x1001);
    address private constant STUDENT_ONE = address(0x2001);
    address private constant STUDENT_TWO = address(0x2002);

    function setUp() public {
        system = new StudentRecordSystem();
        system.activateContract();
    }

    function testConstructorSetsOwnerAndStaffToDeployer() public {
        StudentRecordSystem fresh = new StudentRecordSystem();

        assertEq(fresh.getOwner(), address(this));
        assertEq(fresh.getAdminManager(), address(this));
        assertEq(fresh.getAcademicRecordManager(), address(this));
        assertEq(fresh.getGradesManager(), address(this));
        assertEq(fresh.getRegistrar(), address(this));
        assertEq(fresh.isContractActive(), "NotActive");
    }

    function testOnlyOwnerCanActivateContract() public {
        StudentRecordSystem fresh = new StudentRecordSystem();

        vm.prank(OUTSIDER);
        vm.expectRevert(
            abi.encodeWithSignature("STUDENTRECORDSYSTEM_UNAUTHORIZED_ACCESS(address)", address(this))
        );
        fresh.activateContract();

        fresh.activateContract();
        assertEq(fresh.isContractActive(), "Active");
    }

    function testRegisterStudentStoresData() public {
        system.registerStudent(_studentInput(STUDENT_ONE));

        assertEq(system.studentCount(), 1);
        assertTrue(system.checkIfStudentExist(1));
        assertTrue(system.checkIfStudentAddressExist(STUDENT_ONE));

        StudentLib.Student memory stored = system.getStudentData(1);
        assertEq(stored.fName, "Ada");
        assertEq(stored.mName, "Grace");
        assertEq(stored.lName, "Lovelace");
        assertEq(stored.dept, "Computer Science");
        assertEq(stored.course, "Solidity 101");
        assertEq(stored.location, "Lagos");
        assertEq(stored.mobileNumber, 234_801_234_5678);
        assertEq(stored.studentAddress, STUDENT_ONE);
        assertEq(stored.email, "ada@example.com");
        assertEq(uint8(stored.studentStatus), uint8(StudentTypes.StudentStatus.Active));
        assertEq(system.getStudentStatusAsString(1), "Active");

        StudentLib.Student memory storedByAddress = system.getStudentByAddress(STUDENT_ONE);
        assertEq(storedByAddress.email, "ada@example.com");
        assertEq(storedByAddress.studentAddress, STUDENT_ONE);
    }

    function testRegisterStudentRejectsDuplicateAddress() public {
        system.registerStudent(_studentInput(STUDENT_ONE));

        vm.expectRevert(
            abi.encodeWithSignature("STUDENTRECORDSYSTEM_EXISTING_STUDENT_ADDRESS(address)", STUDENT_ONE)
        );
        system.registerStudent(_studentInput(STUDENT_ONE));
    }

    function testNonRegistrarCannotRegisterStudent() public {
        vm.prank(OUTSIDER);
        vm.expectRevert(
            abi.encodeWithSignature("STUDENTRECORDSYSTEM_UNAUTHORIZED_ACCESS(address)", address(this))
        );
        system.registerStudent(_studentInput(STUDENT_ONE));
    }

    function testUpdateStudentMovesAddressAndData() public {
        system.registerStudent(_studentInput(STUDENT_ONE));
        system.updateStudentRecord(1, _updateInput(STUDENT_TWO));

        StudentLib.Student memory updated = system.getStudentData(1);
        assertEq(updated.fName, "Ada Updated");
        assertEq(updated.mName, "Grace Updated");
        assertEq(updated.lName, "Lovelace Updated");
        assertEq(updated.dept, "Mathematics");
        assertEq(updated.course, "Advanced Solidity");
        assertEq(updated.location, "Abuja");
        assertEq(updated.mobileNumber, 234_802_000_0000);
        assertEq(updated.studentAddress, STUDENT_TWO);
        assertEq(updated.email, "ada.updated@example.com");

        assertFalse(system.checkIfStudentAddressExist(STUDENT_ONE));
        assertTrue(system.checkIfStudentAddressExist(STUDENT_TWO));

        StudentLib.Student memory oldAddressRecord = system.getStudentByAddress(STUDENT_ONE);
        assertEq(oldAddressRecord.studentAddress, address(0));
    }

    function testDeleteStudentClearsData() public {
        system.registerStudent(_studentInput(STUDENT_ONE));
        system.deleteStudent(1, STUDENT_ONE);

        assertFalse(system.checkIfStudentExist(1));
        assertFalse(system.checkIfStudentAddressExist(STUDENT_ONE));

        vm.expectRevert(
            abi.encodeWithSignature("STUDENTRECORDSYSTEM_STUDENT_DOESNT_EXIST()")
        );
        system.getStudentData(1);
    }

    function testAddScoresAndGrades() public {
        system.registerStudent(_studentInput(STUDENT_ONE));

        uint256[] memory courseScores = new uint256[](3);
        courseScores[0] = 90;
        courseScores[1] = 85;
        courseScores[2] = 92;

        uint256[] memory performanceScores = new uint256[](2);
        performanceScores[0] = 75;
        performanceScores[1] = 80;

        uint256[] memory attendanceScores = new uint256[](2);
        attendanceScores[0] = 100;
        attendanceScores[1] = 98;

        system.addStudentScores(1, courseScores, performanceScores, attendanceScores);

        _assertUintArrayEq(system.getStudentCourseScores(1), courseScores);
        _assertUintArrayEq(system.getStudentPerformanceScores(1), performanceScores);
        _assertUintArrayEq(system.getStudentAttendanceScores(1), attendanceScores);

        StudentTypes.Grade[] memory courseGrades = new StudentTypes.Grade[](2);
        courseGrades[0] = StudentTypes.Grade.A;
        courseGrades[1] = StudentTypes.Grade.B;

        StudentTypes.Grade[] memory performanceGrades = new StudentTypes.Grade[](2);
        performanceGrades[0] = StudentTypes.Grade.AB;
        performanceGrades[1] = StudentTypes.Grade.BC;

        StudentTypes.Grade[] memory attendanceGrades = new StudentTypes.Grade[](2);
        attendanceGrades[0] = StudentTypes.Grade.A;
        attendanceGrades[1] = StudentTypes.Grade.A;

        system.addStudentGrades(1, courseGrades, performanceGrades, attendanceGrades);

        _assertUint8ArrayEq(system.getStudentCourseGrades(1), _toUint8Array(courseGrades));
        _assertUint8ArrayEq(system.getStudentPerformanceGrades(1), _toUint8Array(performanceGrades));
        _assertUint8ArrayEq(system.getStudentAttendanceGrades(1), _toUint8Array(attendanceGrades));
    }

    function testEmptyScoreArrayReverts() public {
        system.registerStudent(_studentInput(STUDENT_ONE));

        uint256[] memory emptyScores = new uint256[](0);
        vm.expectRevert(
            abi.encodeWithSignature("STUDENTRECORDSYSTEM_STUDENT_SCORE_CANT_BE_EMPTY()")
        );
        system.addStudentCourseScores(1, emptyScores);
    }

    function testEmptyGradeArrayReverts() public {
        system.registerStudent(_studentInput(STUDENT_ONE));

        StudentTypes.Grade[] memory emptyGrades = new StudentTypes.Grade[](0);
        vm.expectRevert(
            abi.encodeWithSignature("STUDENTRECORDSYSTEM_STUDENT_GRADE_CANT_BE_EMPTY()")
        );
        system.gradeStudentCourse(1, emptyGrades);
    }

    function _studentInput(address studentAddress) internal pure returns (StudentStruct.StudentInput memory) {
        return StudentStruct.StudentInput({
            fName: "Ada",
            mName: "Grace",
            lName: "Lovelace",
            dateOfBirth: 20000101,
            studentGender: StudentTypes.StudentGender.Female,
            studentStatus: StudentTypes.StudentStatus.Active,
            dept: "Computer Science",
            course: "Solidity 101",
            location: "Lagos",
            mobileNumber: 234_801_234_5678,
            studentAddress: studentAddress,
            email: "ada@example.com",
            timestamp: 0
        });
    }

    function _updateInput(address studentAddress) internal pure returns (StudentStruct.UpdateStudentInput memory) {
        return StudentStruct.UpdateStudentInput({
            newFName: "Ada Updated",
            newMName: "Grace Updated",
            newLName: "Lovelace Updated",
            newDateOfBirth: 20010101,
            newDept: "Mathematics",
            newCourse: "Advanced Solidity",
            newLocation: "Abuja",
            newMobileNumber: 234_802_000_0000,
            newEmail: "ada.updated@example.com",
            newStudentAddress: studentAddress
        });
    }

    function _assertUintArrayEq(uint256[] memory actual, uint256[] memory expected) internal pure {
        assertEq(actual.length, expected.length);
        for (uint256 i = 0; i < actual.length; i++) {
            assertEq(actual[i], expected[i]);
        }
    }

    function _assertUint8ArrayEq(uint8[] memory actual, uint8[] memory expected) internal pure {
        assertEq(actual.length, expected.length);
        for (uint256 i = 0; i < actual.length; i++) {
            assertEq(actual[i], expected[i]);
        }
    }

    function _toUint8Array(StudentTypes.Grade[] memory grades) internal pure returns (uint8[] memory) {
        uint8[] memory result = new uint8[](grades.length);
        for (uint256 i = 0; i < grades.length; i++) {
            result[i] = uint8(grades[i]);
        }
        return result;
    }
}