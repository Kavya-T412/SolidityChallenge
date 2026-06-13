// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// AdminManager contract to  manage staff roles and permissions

error STUDENTRECORDSYSTEM_UNAUTHORIZED_ACCESS();
error STUDENTRECORDSYSTEM_NOT_A_STAFF_MEMBER();
error STUDENTRECORDSYSTEM_STAFFADDRESS_CANT_BE_ZERO_ADDRESS();

contract AdminManager {
    address internal adminManager;
    address internal academicRecordManager;
    address internal gradesManager;
    address internal studentRegistrar;

    event AdminManagerAssigned(address indexed staffAddress);
    event AcademicRecordManagerAssigned(address indexed staffAddress);
    event GradesManagerAssigned(address indexed staffAddress);
    event StudentRegistrarAssigned(address indexed staffAddress);

    // Sets contract deployer as admin manager
    constructor() {
        adminManager = msg.sender;
    }

    // Restricts access to only admin manager
    modifier isAdminManager(){
        if(msg.sender != adminManager) revert STUDENTRECORDSYSTEM_UNAUTHORIZED_ACCESS();
        _;
    }

    // Restricts access to only staff members
    modifier onlyStaff(){
        if(msg.sender != studentRegistrar &&
           msg.sender != academicRecordManager &&
           msg.sender != gradesManager) revert STUDENTRECORDSYSTEM_NOT_A_STAFF_MEMBER();
        _;
    }

    // Assigns academic record manager
    function assignAcademicRecordManager(address _staffAddress) external isAdminManager{
        if(_staffAddress == address(0)) revert STUDENTRECORDSYSTEM_STAFFADDRESS_CANT_BE_ZERO_ADDRESS();
        academicRecordManager = _staffAddress;
        emit AcademicRecordManagerAssigned(_staffAddress);
    }

    // Assigns grades manager
    function assignGradesManager(address _staffAddress) external isAdminManager{
        if(_staffAddress == address(0)) revert STUDENTRECORDSYSTEM_STAFFADDRESS_CANT_BE_ZERO_ADDRESS();
        gradesManager = _staffAddress;
        emit GradesManagerAssigned(_staffAddress);
    }

    // Assigns student registrar
    function assignStudentRegistrar(address _staffAddress) external isAdminManager{
        if(_staffAddress == address(0)) revert STUDENTRECORDSYSTEM_STAFFADDRESS_CANT_BE_ZERO_ADDRESS();
        studentRegistrar = _staffAddress;
        emit StudentRegistrarAssigned(_staffAddress);
    }

    // Returns student registrar's address
    function getRegistrar() external view returns(address){
        return studentRegistrar;
    }

    // Returns grade manager's address
    function getGradesManager() external view returns(address){
        return gradesManager;
    }

    // Returns Academic record manager's address
    function getAcademicRecordManager() external view returns(address){
        return academicRecordManager;
    }

    // Returns admin manager's address
    function getAdminManager() external view returns(address){
        return adminManager;
    }

    // Returns all staff members' addresses
    function getAllStaff() external view returns(address _adminManager, address _academicManager, address _gradesManager, address _studentRegistrar){
        return (adminManager, academicRecordManager, gradesManager, studentRegistrar);
    }
}