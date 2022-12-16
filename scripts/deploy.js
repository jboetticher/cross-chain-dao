// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  // Deploy the IVotes implementation
  const CrossChainDAOToken = await hre.ethers.getContractFactory("CrossChainDAOToken");
  const hundredTokens = hre.ethers.utils.parseEther("100");
  const token = await CrossChainDAOToken.deploy(hundredTokens);
  console.log("CrossChainDAOToken deployed to: " + token.address);

  // Now deploy the cross-chain token
  const CrossChainDAO = await hre.ethers.getContractFactory("CrossChainDAO");
  const dao = await CrossChainDAO.deploy(token.address);
  console.log("CrossChainDAO deployed to: " + dao.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
