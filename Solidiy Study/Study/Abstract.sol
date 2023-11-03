// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 抽象合约，不可部署
abstract contract Base{
    string public name = "Base";
    function get()public pure virtual returns(string memory); 
}
// 继承抽象合约，可以部署
contract Baseimpl is Base{
    function get()public pure override returns(string memory){
        return "Impl";
    }

}