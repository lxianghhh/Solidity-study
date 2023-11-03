// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract text{
    //状态变量 储存在链上
    uint[] x = [1,2,3]; 
    uint public y;
    string public z;
    //可以用函数改变状态变量的值
    function change()public {
        y = 2;
        z = "hello";
    }
    //局部变量 储存在内存里
    function bar() external pure returns(uint){
    uint xx = 1;
    uint yy = 3;
    uint zz = xx + yy;
    return(zz);
    }
    //全局变量 可以不声明直接使用
    function global() external view returns(address, uint, bytes memory){
    address sender = msg.sender;
    uint blockNum = block.number;
    bytes memory data = msg.data;
    return(sender, blockNum, data);
    }

    //storage赋值给strorage
    function fStorage() public returns(uint) {
        //声明一个storage的变量 xStorage，指向x。修改xStorage也会影响x
        uint[] storage xStorage = x;
        xStorage[0] = 100;
        return x[0];
    }

    //storage赋值给memory
    function fMemory() public view{
        //声明一个Memory的变量xMemory，复制x。修改xMemory不会影响x
        uint[] memory xMemory = x;
        xMemory[0] = 100;
        xMemory[1] = 200;
        uint[] memory xMemory2 = x;
        xMemory2[0] = 300;
    }

    function fCalldata(uint[] calldata _x) public pure returns(uint[] calldata){
    //参数为calldata数组，不能被修改
    // _x[0] = 0 //这样修改会报错
    return(_x);
    }
}