//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.7;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import { IConstantFlowAgreementV1 } from "@superfluid-finance/ethereum-contracts/contracts/interfaces/agreements/IConstantFlowAgreementV1.sol";

contract HambergerNFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    //TokenID counter so that each NFT has a unique tokenID
    Counters.Counter private _tokenIds;
    uint256 public lastMintedOn;

    constructor() ERC721("HambergerNFT", "HMT") {
        lastMintedOn = block.timestamp;
        console.log("Timestamp: ", lastMintedOn);
        console.log("HambergerNFT contract created");
    }

    function mint() public {
        //mint a new token
        uint256 tokenId = _tokenIds.current();
        _tokenIds.increment();
        _mint(msg.sender, tokenId);
    }

    function getCurrentBlockTime() external view returns (uint) {
        return block.timestamp;
    }
}
