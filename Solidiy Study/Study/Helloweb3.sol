// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Hello{
    string private str = "Hello web3.0";
    function hello()public view returns(string memory st)
    {
        return str;
    } 

}