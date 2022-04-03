// import { expect } from "chai";
// import { BigNumber } from "ethers";
import { ethers } from "hardhat";

// eslint-disable-next-line promise/param-names
// const delay = (ms: number) => new Promise((res) => setTimeout(res, ms));

describe("HambergerNFT", function () {
  it("Should shuffle the array", async function () {
    const Greeter = await ethers.getContractFactory("HambergerNFT");
    const greeter = await Greeter.deploy();
    await greeter.deployed();
  });
});
