// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract test{
    uint public num1 = 3;

    //pure 不可读取状态变量，也不能改写
    function add1(uint num0 )external pure returns(uint n) {
        return num0 + 1;
    }
    // view 可以读取，不能改改写
    function add2()public view returns(uint n2){
        return num1 + 1;
    } 

    // internal 只能内部调用
    function minus() internal {
        num1 = num1 - 1;
    }

    // external 只能外部调用 合约内的函数可以调用内部函数
    function minusCall() external {
        minus();
    }

    // payable: 递钱，能给合约支付eth的函数
    function minusPayable() external payable returns(uint256 balance) {
        minus();    
        balance = address(this).balance ;
    }
}
