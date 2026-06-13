// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// Library for StudentRecordSystem

import {StudentTypes} from "./StudentTypes.sol";

library StudentUtils{

    function statusToString(StudentTypes.StudentStatus status) internal pure returns(string memory){
        
        // converts the enum value to a string 
        if(status == StudentTypes.StudentStatus.Active) return "Active"; // Returns `Active` if status is 0
        if(status == StudentTypes.StudentStatus.Suspended) return "Suspended"; // Returns `Suspended` if status is 1
        if(status == StudentTypes.StudentStatus.Graduated) return "Graduated"; // Returns `Graduated` if status is 2
        if(status == StudentTypes.StudentStatus.Expelled) return "Expelled"; // Returns `Expelled` if status is 3
        
        return "Unknown";
    }
}