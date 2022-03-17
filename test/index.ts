// import { expect } from "chai";
// import { BigNumber } from "ethers";
import { ethers } from "hardhat";

// eslint-disable-next-line promise/param-names
const delay = (ms: number) => new Promise((res) => setTimeout(res, ms));

describe("HambergerNFT", function () {
  it("Should return the difference between the current block time and the time the contract was deployed", async function () {
    const Greeter = await ethers.getContractFactory("HambergerNFT");
    const greeter = await Greeter.deploy();
    await greeter.deployed();

    const deployBlockTime = await greeter.getCurrentBlockTime();
    console.log("Contract deployed at: ", deployBlockTime);

    await delay(5000);

    const currentBlockTime = await greeter.getCurrentBlockTime();
    console.log("Current block time: ", currentBlockTime);

    const difference = currentBlockTime.sub(deployBlockTime);
    console.log("Difference: ", difference);
  });
});
