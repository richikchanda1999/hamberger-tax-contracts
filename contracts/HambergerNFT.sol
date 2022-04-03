//SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.7 <0.9.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

import {ISuperfluid} from "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperfluid.sol";
import {IConstantFlowAgreementV1} from "@superfluid-finance/ethereum-contracts/contracts/interfaces/agreements/IConstantFlowAgreementV1.sol";
import {CFAv1Library} from "@superfluid-finance/ethereum-contracts/contracts/apps/CFAv1Library.sol";
import {ISuperfluidToken} from "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperToken.sol";

import "./Treasury.sol";
import "./RedirectAll.sol";

contract HambergerNFT is ERC721Enumerable, ReentrancyGuard, Ownable {
    using CFAv1Library for CFAv1Library.InitData;

    //initialize cfaV1 variable
    CFAv1Library.InitData public cfaV1;
    uint256[] public nft_values;
    uint256 public lastMintedOn;

    ISuperfluid private _host;
    ISuperToken private _token;
    IConstantFlowAgreementV1 private _cfa;
    address public _treasuryAddress;

    constructor(
        ISuperfluid host,
        ISuperToken token,
        address treasuryAddress
    ) ERC721("HambergerNFT", "HMT") {
        assert(address(host) != address(0));
        assert(address(token) != address(0));
        assert(address(treasuryAddress) != address(0));

        _host = host;
        _token = token;
        _treasuryAddress = treasuryAddress;

        _cfa = IConstantFlowAgreementV1(
            address(
                host.getAgreementClass(
                    keccak256(
                        "org.superfluid-finance.agreements.ConstantFlowAgreement.v1"
                    )
                )
            )
        );

        cfaV1 = CFAv1Library.InitData(_host, _cfa);
    }

    function tokenURI(uint256 tokenId)
        public
        pure
        override
        returns (string memory)
    {
        string
            memory description = "There are 8 circles of 8 different colours who intersect once every 24 hours";

        string
            memory svg = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 400 400" preserveAspectRatio="xMinYMin">'
            "<style>"
            ".circle {"
            "r: 25;"
            "}"
            "</style>"
            '<rect width="400" height="400" fill="black" />'
            '<circle class="circle" fill="violet">'
            '<animate attributeName="cx" values="-25;200;-25" dur="4s" repeatCount="indefinite"/>'
            '<animate attributeName="cy" values="-25;200;-25" dur="4s" repeatCount="indefinite"/>'
            "</circle>"
            '<circle class="circle" cx="200" fill="indigo">'
            '<animate attributeName="cy" values="-25;200;-25" dur="4s" repeatCount="indefinite" />'
            "</circle>"
            '<circle class="circle" fill="blue">'
            '<animate attributeName="cx" values="425;200;425" dur="4s" repeatCount="indefinite" />'
            '<animate attributeName="cy" values="-25;200;-25" dur="4s" repeatCount="indefinite" />'
            "</circle>"
            '<circle class="circle" cy="200" fill="green">'
            '<animate attributeName="cx" values="425;200;425" dur="4s" repeatCount="indefinite" />'
            "</circle>"
            '<circle class="circle" fill="yellow">'
            '<animate attributeName="cx" values="425;200;425" dur="4s" repeatCount="indefinite" />'
            '<animate attributeName="cy" values="425;200;425" dur="4s" repeatCount="indefinite" />'
            "</circle>"
            '<circle class="circle" cx="200" fill="orange">'
            '<animate attributeName="cy" values="425;200;425" dur="4s" repeatCount="indefinite" />'
            "</circle>"
            '<circle class="circle" fill="red">'
            '<animate attributeName="cx" values="-25;200;-25" dur="4s" repeatCount="indefinite" />'
            '<animate attributeName="cy" values="425;200;425" dur="4s" repeatCount="indefinite" />'
            "</circle>"
            '<circle class="circle" cy="200" fill="white">'
            '<animate attributeName="cx" values="-25;200;-25" dur="4s" repeatCount="indefinite" />'
            "</circle>"
            "</svg>";

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "Hamburger #',
                        toString(tokenId),
                        '", "description": "',
                        description,
                        '", "image": "data:image/svg+xml;base64,',
                        Base64.encode(bytes(svg)),
                        '"}'
                    )
                )
            )
        );
        string memory output = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        return output;
    }

    function mint(uint256 tokenId, uint256 new_nft_value) public nonReentrant {
        require(
            // block.timestamp - lastMintedOn > 86400,
            block.timestamp - lastMintedOn > 30,
            "Cannot mint more than once in 30 seconds"
        );

        lastMintedOn = block.timestamp;

        _safeMint(_msgSender(), tokenId);
        nft_values[tokenId] = new_nft_value;

        (, int96 flowRate, , ) = _cfa.getFlow(
            _token,
            _msgSender(),
            _treasuryAddress
        );
        flowRate = flowRate + int96(int256(uint256(new_nft_value / (30 * 24 * 3600 * 100))));
        cfaV1.createFlow(_treasuryAddress, _token, flowRate);
    }

    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT license
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    // claim NFT from owner who has stopped paying rent
    function claim(uint tokenId, uint new_nft_value) public {
        // if streaming rent inactive
        //  transfer NFT

        address currentOwner = ownerOf(tokenId);
        uint256 value = _token.balanceOf(currentOwner);
        require(value == 0, "Cannot claim now!");

        nft_values[tokenId] = new_nft_value;
        _safeTransfer(currentOwner, _msgSender(), tokenId, _data);
    }

    function buy(uint tokenId, uint new_nft_value) public payable {
        
        // if nft_value[tokenId] < msg.amount
        //   transfer NFT
    }

    function getBlockTime() public view returns (uint256) {
        return block.timestamp;
    }
}
