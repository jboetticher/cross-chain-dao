// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  // Deploy the cross-chain token 
  const VoteAggregator = await hre.ethers.getContractFactory("VoteAggregator");
  const hundredTokens = hre.ethers.utils.parseEther("100");
  const token = await CrossChainDAOToken.deploy(hundredTokens);
  console.log("CrossChainDAOToken deployed to: " + token.address);

  // Lz Addresses
  const addresses = {
    "1287": "0xb23b28012ee92E8dE39DEb57Af31722223034747",
    "4002": "0x7dcAD72640F835B0FA36EFD3D6d3ec902C7E5acf",
    "43113": "0x93f54D755A063cE7bB9e6Ac47Eccc8e33411d706",
  };
  let lzAddress = addresses[hre.getChainId()];

  // Now deploy the DAO
  const CrossChainDAO = await hre.ethers.getContractFactory("CrossChainDAO");
  const dao = await CrossChainDAO.deploy(token.address, lzAddress, [10112, 10106]); // fantom + avalanche
  console.log("CrossChainDAO deployed to: " + dao.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
