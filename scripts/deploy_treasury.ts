import { ethers } from "hardhat";

async function main() {
  const TreasuryContract = await ethers.getContractFactory("Treasury");
  const hambergerNFT = await TreasuryContract.deploy();

  await hambergerNFT.deployed();

  console.log("Treasury Contract deployed to:", hambergerNFT.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
