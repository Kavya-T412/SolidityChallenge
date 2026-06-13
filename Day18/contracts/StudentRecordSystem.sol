// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {AdminManager} from "./AdminManager.sol";
import {GradesManager} from "./GradesManager.sol";
import {StudentRegistry} from "./StudentRegistry.sol";
import {AcademicRecordManager} from "./AcademicRecordManager.sol";
import {Utils} from "./Utils.sol";
import {StudentLib} from "./StudentLib.sol";
import {StudentTypes} from "./StudentTypes.sol";
import {StudentUtils} from "./StudentUtils.sol";
import {StudentStruct} from "./StudentStructs.sol";

error STUDENTRECORDSYSTEM_INVALID_ADDRESS();
error STUDENTRECORDSYSTEM_UNAUTHORIZED_ACCESS();

contract StudentRecordSystem is AdminManager, Utils, StudentRegistry, AcademicRecordManager, GradesManager{
    using StudentLib for StudentLib.StudentStorage;

    constructor(){
        owner = msg.sender;
        academicRecordManager = msg.sender;
        gradesManager = msg.sender;
        studentRegistrar = msg.sender;
    }

    // Register's student
    function registerStudent(StudentStruct.StudentInput memory input) external isRegistrar isActive{
        register(input); // Calls internal register() from StudentRegistry
    }

    // Bulk register students
    function registerMany(StudentStruct.StudentInput[] memory inputs) external isRegistrar isActive{
        for(uint256 i=0; i<inputs.length; i++){
            register(inputs[i]); 
        }
    }

    // Updates student info
    function updateStudentRecord(uint256 _studentId, StudentStruct.UpdateStudentInput memory input) external isRegistrar isActive{
        updateStudent(_studentId, input); // Calls internal updateStudent() from StudentRegistry
    }

    // Deletes student data
    function deleteStudent(uint256 _studentId, address _studentAddress) external isRegistrar isActive{
        deleteStudentData(_studentId, _studentAddress); // Calls internal deleteStudentData() from StudentRegistry
    }

    // Stores student scores
    function addStudentCourseScores(uint256 _studentId, uint256[] memory _scores) external isAcademicManager isActive{
        addCourseScore(_studentId, _scores); // Calls internal addCourseScore() from GradesManager
    }

    // Stores student's class performance scores
    function addStudentClassPerformanceScores(uint256 _studentId, uint256[] memory _scores) external isAcademicManager isActive{
        addClassPerformanceScore(_studentId, _scores); // Calls internal addClassPerformanceScore() from GradesManager
    }

    // Stores student's attendance score
    function addStudentAttendanceScores(uint256 _studentId, uint256[] memory _scores) external isAcademicManager isActive{
        addAttendanceScore(_studentId, _scores); // Calls internal addAttendanceScore() from GradesManager
    }

    // Stores all student's scores at once
    function addStudentScores(uint256 _studentId, uint256[] memory _courseScores, uint256[] memory _performanceScores, uint256[] memory _attendanceScores) external isAcademicManager isActive{
        addAllScore(_studentId, _courseScores, _performanceScores, _attendanceScores); // Calls internal addAllScore() from GradesManager
    }

    // Grades student's course
    function gradeStudentCourse(uint256 _studentId, StudentTypes.Grade[] memory _grades) external isGradesManager isActive {
        gradeCourse(_studentId, _grades); // Calls internal gradeCourse() from GradesManager
    }

    // Grades student's performance
    function gradeStudentPerformance(uint256 _studentId, StudentTypes.Grade[] memory _grades) external isGradesManager isActive {
        gradePerformance(_studentId, _grades); // Calls internal gradePerformance() from GradesManager
    }

    // Grades student's attendance
    function gradeStudentAttendance(uint256 _studentId, StudentTypes.Grade[] memory _grades) external isGradesManager isActive {
        gradeAttendance(_studentId, _grades); // Calls internal gradeAttendance() from GradesManager
    }

    // Grades all student's scores at once
    function addStudentGrades(uint256 _studentId, StudentTypes.Grade[] memory _courseGrades, StudentTypes.Grade[] memory _performanceGrades, StudentTypes.Grade[] memory _attendanceGrades) external isGradesManager isActive {
        gradeAll(_studentId, _courseGrades, _performanceGrades, _attendanceGrades); // Calls internal gradeAll() from GradesManager
    }

    // Returns student's data
    function getStudentData(uint256 _studentId) public view returns(StudentLib.Student memory) {
        return studentStore.getStudent(_studentId); //from lib
    }

    // Returns student's status as unsigned integer (0,1,2,3)
    function getStudentStatus(uint256 _studentId) public view returns (StudentTypes.StudentStatus) {
        return StudentTypes.StudentStatus(studentStore.getStudent(_studentId).studentStatus);
    }

    // Returns student's status as string
    function getStudentStatusAsString(uint256 _studentId) public view returns (string memory){
        StudentTypes.StudentStatus statusEnum = StudentTypes.StudentStatus(studentStore.getStudent(_studentId).studentStatus);
        return StudentUtils.statusToString(statusEnum);
    }

    // Returns student's data
    function getStudentByAddress(address _studentAddress) public view returns(StudentLib.Student memory){
        return studentStore.studentsByAddress[_studentAddress]; // From lib
    }

    // Checks the student's existance using id
    function checkIfStudentExist(uint256 _studentId) public view returns (bool) {
        return studentStore.exist(_studentId); // From lib
    }

    // Checks the student's existance using address
    function checkIfStudentAddressExist(address _studentAddress) public view returns (bool) {
        return studentStore.existAddress(_studentAddress); // From lib
    }

    // Returns student's course scores
    function getStudentCourseScores(uint256 _studentId) public view returns(uint256[] memory){
        return studentStore.studentRecords[_studentId].courseScores;
    }

    // Returns student's class performance score
    function getStudentPerformanceScores(uint256 _studentId) public view returns(uint256[] memory){
        return studentStore.studentRecords[_studentId].performanceScores;
    }

    // Returns student's class attendance scores
    function getStudentAttendanceScores(uint256 _studentId) public view returns(uint256[] memory){
        return studentStore.studentRecords[_studentId].attendanceScores;
    }

    // Returns student's course grades
    function getStudentCourseGrades(uint256 _studentId) public view returns(uint8[] memory){
        StudentLib.StudentRecord storage student = studentStore.studentRecords[_studentId];
        uint256 len = student.courseGrades.length;
        uint8[] memory result = new uint8[](len);
        for(uint256 i=0; i<len; i++){
            result[i] = uint8(student.courseGrades[i]);
        }
        return result;
    }

    // Returns student's performance grades
    function getStudentPerformanceGrades(uint256 _studentId) public view returns(uint8[] memory){
        StudentLib.StudentRecord storage student = studentStore.studentRecords[_studentId];
        uint256 len = student.performanceGrades.length;
        uint8[] memory result = new uint8[](len);
        for(uint256 i=0; i<len; i++){
            result[i] = uint8(student.performanceGrades[i]);
        }
        return result;
    }

    //Returns student's attendance grades
    function getStudentAttendanceGrades(uint256 _studentId) public view returns(uint8[] memory){
        StudentLib.StudentRecord storage student = studentStore.studentRecords[_studentId];
        uint256 len = student.attendanceGrades.length;
        uint8[] memory result = new uint8[](len);
        for(uint256 i=0; i<len; i++){
            result[i] = uint8(student.attendanceGrades[i]);
        }
        return result;
    }
}