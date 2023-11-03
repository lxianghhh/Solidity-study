//SPDX-License-Identifier: MIT
//作者：叶力涛
pragma solidity ^0.8.18;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

//铸造NFT合约
contract MintNFT is ERC721 {
    uint256 public tokenId;

    constructor(string memory _name, string memory _symbol)
        ERC721(_name, _symbol)
    {}

    function mint(address _to, uint256 _tokenId) public {
        require(_tokenId > 0, "Token ID should be greater than 0");

        _mint(_to, _tokenId);

        tokenId = _tokenId;
    }
}