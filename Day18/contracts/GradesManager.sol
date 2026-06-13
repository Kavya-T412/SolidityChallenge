// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

//GradesManager contract for StudentRecordSystem

import {StudentRegistry} from "./StudentRegistry.sol";
import {Utils} from "./Utils.sol";
import {StudentLib} from "./StudentLib.sol";
import {StudentTypes} from "./StudentTypes.sol";

error STUDENTRECORDSYSTEM_STUDENT_GRADE_CANT_BE_EMPTY();
error STUDENTRECORDSYSTEM_STUDENT_DOSENT_EXIST(uint256 studentId);
error STUDENTRECORDSYSTEM_STUDENT_ADDRESS_DOSENT_EXIST(address studentAddress);

contract GradesManager is Utils, StudentRegistry {
    
    using StudentLib for StudentLib.StudentStorage;

    event StudentCoursesGraded(uint256 indexed studentId, StudentTypes.Grade[] studentGrades);
    event StudentPerformanceGraded(uint256 indexed studentId, StudentTypes.Grade[] studentGrades);
    event StudentAttendanceGraded(uint256 indexed studentId, StudentTypes.Grade[] studentGrades);
    event AllGradesAdded(uint256 indexed studentId, StudentTypes.Grade[] courseGrades, StudentTypes.Grade[] performanceGrades, StudentTypes.Grade[] attendanceGrades);

    // Grades student's courses
    function gradeCourse(uint256 _studentId, StudentTypes.Grade[] memory _grades) internal isGradesManager isActive {
        if(!studentStore.existingStudent[_studentId]) revert STUDENTRECORDSYSTEM_STUDENT_DOSENT_EXIST(_studentId);
        if(_grades.length <= 0 ) revert STUDENTRECORDSYSTEM_STUDENT_GRADE_CANT_BE_EMPTY();

        StudentLib.StudentRecord storage record = studentStore.studentRecords[_studentId];
        record.courseGrades = _grades;
        record.timestamp = block.timestamp;

        emit StudentCoursesGraded(_studentId, _grades);
    }

    // Grades student's performance
    function gradePerformance(uint256 _studentId, StudentTypes.Grade[] memory _grades) internal isGradesManager isActive {
        if(!studentStore.existingStudent[_studentId]) revert STUDENTRECORDSYSTEM_STUDENT_DOSENT_EXIST(_studentId);
        if(_grades.length <= 0 ) revert STUDENTRECORDSYSTEM_STUDENT_GRADE_CANT_BE_EMPTY();

        StudentLib.StudentRecord storage record = studentStore.studentRecords[_studentId];
        record.performanceGrades = _grades;
        record.timestamp = block.timestamp;

        emit StudentPerformanceGraded(_studentId, _grades);
    }

    // Grades student's attendance
    function gradeAttendance(uint256 _studentId, StudentTypes.Grade[] memory _grades) internal isGradesManager isActive {
        if(!studentStore.existingStudent[_studentId]) revert STUDENTRECORDSYSTEM_STUDENT_DOSENT_EXIST(_studentId);
        if(_grades.length <= 0 ) revert STUDENTRECORDSYSTEM_STUDENT_GRADE_CANT_BE_EMPTY();

        StudentLib.StudentRecord storage record = studentStore.studentRecords[_studentId];
        record.attendanceGrades = _grades;
        record.timestamp = block.timestamp;

        emit StudentAttendanceGraded(_studentId, _grades);
    }

    // Grades all student's records at once
    function gradeAll(uint256 _studentId, StudentTypes.Grade[] memory _courseGrades, StudentTypes.Grade[] memory _performanceGrades, StudentTypes.Grade[] memory _attendanceGrades) internal isGradesManager isActive {
        if(!studentStore.existingStudent[_studentId]) revert STUDENTRECORDSYSTEM_STUDENT_DOSENT_EXIST(_studentId);
        if(_courseGrades.length <= 0 || _performanceGrades.length <= 0 || _attendanceGrades.length <= 0) revert STUDENTRECORDSYSTEM_STUDENT_GRADE_CANT_BE_EMPTY();

        StudentLib.StudentRecord storage record = studentStore.studentRecords[_studentId];
        record.courseGrades = _courseGrades;
        record.performanceGrades = _performanceGrades;
        record.attendanceGrades = _attendanceGrades;
        record.timestamp = block.timestamp;

        emit AllGradesAdded(_studentId, _courseGrades, _performanceGrades, _attendanceGrades);
    }
}