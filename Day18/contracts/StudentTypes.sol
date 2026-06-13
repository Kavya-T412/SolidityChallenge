// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// Library for StudentRecordSystem

library StudentTypes{
    
    // Defines student's gender male(0) and female(1)
    enum StudentGender{Male, Female}

    // Defines student's status active(0), suspended(1), graduated(2) and expelled(3)
    enum StudentStatus{Active, Suspended, Graduated, Expelled}
    
    // Defines student's grade from A(0) to F(6)
    enum Grade{A, AB, B, BC, D, E, F}
}