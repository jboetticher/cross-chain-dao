const CHAIN_ID = require("../constants/chainIds.json")
const { getDeploymentAddresses } = require("../utils/readStatic")

module.exports = async function (taskArgs, hre) {
    const dstChainId = CHAIN_ID[taskArgs.targetNetwork];
    const token = await ethers.getContract("CrossChainDAOToken");

    console.log(`[source] CrossChainDAOToken.address: ${token.address}`);
    try {
        let votes = await token.getVotes("0x0394c0EdFcCA370B20622721985B577850B0eb75");
        console.log(`[source] CrossChainDAOToken.getVotes(0x0394c0EdFcCA370B20622721985B577850B0eb75):`, votes);
    }
    catch(e) {
        console.log(`[source] CrossChainDAOToken.getVotes ERROR!`);
        console.log(`[source]`, e);
    }
}
