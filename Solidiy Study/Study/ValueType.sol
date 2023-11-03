// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract text{
// Value type
    //整型
    uint public  num1 = 2;
    uint public  num1_1 = num1**3;
    uint public  num2 = 3;
    bool public  flag = num1 > num2;
    //地址型
    address public  me = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
    address payable public other = payable(me);//可用send和transfer函数
    uint public balance = other.balance;
    //定长数组
    bytes32 public _byte32 = "MiniSolidity"; 
    bytes1 public _byte = _byte32[0]; 
}