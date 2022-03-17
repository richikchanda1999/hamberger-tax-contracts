//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.7;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import {IConstantFlowAgreementV1} from "@superfluid-finance/ethereum-contracts/contracts/interfaces/agreements/IConstantFlowAgreementV1.sol";

contract HambergerNFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    //TokenID counter so that each NFT has a unique tokenID
    Counters.Counter private _tokenIds;

    uint256 public lastMintedOn;

    constructor() ERC721("HambergerNFT", "HMT") {
        lastMintedOn = 0;
    }

    function mint(uint256 tokenId, uint256 new_nft_value) public {
        require(
            block.timestamp - lastMintedOn > 86400,
            "Cannot mint more than once in 24 hours"
        );

        lastMintedOn = block.timestamp;

        //mint a new token
        uint256 tokenId = _tokenIds.current();
        _tokenIds.increment();
        _mint(msg.sender, tokenId);

        //Create a stream
    }

    // claim NFT from owner who has stopped paying rent
    function claim(uint256 tokenId, uint256 new_nft_value) public {
        // if streaming rent inactive
        //  transfer NFT
    }

    function buy(uint256 tokenId, uint256 new_nft_value) public payable {
        // if nft_value[tokenId] < msg.amount
        //   transfer NFT
    }

    function getBlockTime() public view returns (uint256) {
        return block.timestamp;
    }
}
