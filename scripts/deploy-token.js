
const hre = require("hardhat");

async function main() {
  // Deploy the cross-chain token 
  const CrossChainDAOToken = await hre.ethers.getContractFactory("CrossChainDAOToken");
  const thousandTokens = hre.ethers.utils.parseEther("1000");
  const token = await CrossChainDAOToken.deploy(thousandTokens);
  console.log("CrossChainDAOToken deployed to: " + token.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
