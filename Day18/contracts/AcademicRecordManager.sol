// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {StudentRegistry} from "./StudentRegistry.sol";
import {Utils} from "./Utils.sol";
import {StudentLib} from "./StudentLib.sol";
import {StudentTypes} from "./StudentTypes.sol";
import {StudentStruct} from "./StudentStructs.sol";

error STUDENTRECORDSYSTEM_STUDENT_SCORE_CANT_BE_EMPTY();
error STUDENTRECORDSYSTEM_STUDENT_DOESNT_EXIST(uint256 studentId);

contract AcademicRecordManager is StudentRegistry {
    event CourseScoreAdded(uint256 indexed studentId, uint256[] score);
    event PerformanceScoreAdded(uint256 indexed studentId, uint256[] score);
    event AttendanceScoreAdded(uint256 indexed studentId, uint256[] score);
    event AllScoresAdded(uint256 indexed studentId, uint256[] courseScores, uint256[] performanceScore, uint256[] attendanceScore);
    
    // Stores student's scores
    function addCourseScore(uint256 _studentId, uint256[] memory _scores) internal isAcademicManager isActive{
        if(!studentStore.existingStudent[_studentId]) revert STUDENTRECORDSYSTEM_STUDENT_DOESNT_EXIST(_studentId);
        if(_scores.length == 0) revert STUDENTRECORDSYSTEM_STUDENT_SCORE_CANT_BE_EMPTY();
        StudentLib.StudentRecord storage student = studentStore.studentRecords[_studentId];
        student.courseScores = (_scores);
        student.timestamp = block.timestamp;

        emit CourseScoreAdded(_studentId, _scores);
    }

    // Stores student's class performance scores
    function addClassPerformanceScore(uint256 _studentId, uint256[] memory _scores) internal isAcademicManager isActive{
        if(!studentStore.existingStudent[_studentId]) revert STUDENTRECORDSYSTEM_STUDENT_DOESNT_EXIST(_studentId);
        if(_scores.length == 0) revert STUDENTRECORDSYSTEM_STUDENT_SCORE_CANT_BE_EMPTY();
        StudentLib.StudentRecord storage student = studentStore.studentRecords[_studentId];
        student.performanceScores = (_scores);
        student.timestamp = block.timestamp;

        emit PerformanceScoreAdded(_studentId, _scores);
    }

    // Stores student's attendance scores
    function addAttendanceScore(uint256 _studentId, uint256[] memory _scores) internal isAcademicManager isActive{
        if(!studentStore.existingStudent[_studentId]) revert STUDENTRECORDSYSTEM_STUDENT_DOESNT_EXIST(_studentId);
        if(_scores.length == 0) revert STUDENTRECORDSYSTEM_STUDENT_SCORE_CANT_BE_EMPTY();
        StudentLib.StudentRecord storage student = studentStore.studentRecords[_studentId];
        student.attendanceScores = (_scores);
        student.timestamp = block.timestamp;

        emit AttendanceScoreAdded(_studentId, _scores);
    }

    // Stores all student's scores at once
    function addAllScore(uint256 _studentId, uint256[] memory _courseScores, uint256[] memory _performanceScores, uint256[] memory _attendanceScores) internal isAcademicManager isActive{
        if(!studentStore.existingStudent[_studentId]) revert STUDENTRECORDSYSTEM_STUDENT_DOESNT_EXIST(_studentId);
        if(_courseScores.length == 0 || _performanceScores.length == 0 || _attendanceScores.length == 0) revert STUDENTRECORDSYSTEM_STUDENT_SCORE_CANT_BE_EMPTY();
        
        StudentLib.StudentRecord storage student = studentStore.studentRecords[_studentId];
        student.courseScores = (_courseScores);
        student.performanceScores = (_performanceScores);
        student.attendanceScores = (_attendanceScores);
        student.timestamp = block.timestamp;

        emit AllScoresAdded(_studentId, _courseScores, _performanceScores, _attendanceScores);
    }
}
