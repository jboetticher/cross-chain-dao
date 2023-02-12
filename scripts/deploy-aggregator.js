// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  // Get the deployment of the token on this chain
  const token = "";

  // Lz Addresses
  const addresses = {
    "1287": "0xb23b28012ee92E8dE39DEb57Af31722223034747",
    "4002": "0x7dcAD72640F835B0FA36EFD3D6d3ec902C7E5acf",
    "43113": "0x93f54D755A063cE7bB9e6Ac47Eccc8e33411d706",
  };
  let lzAddress = addresses[hre.getChainId()];

  // Deploy the aggregator
  const DAOSatellite = await hre.ethers.getContractFactory("DAOSatellite");
  const dao = await DAOSatellite.deploy(10126, lzAddress, token); // fantom + avalanche
  console.log("CrossChainDAO deployed to: " + dao.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
