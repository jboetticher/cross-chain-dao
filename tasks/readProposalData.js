const CHAIN_ID = require("../constants/chainIds.json")
const { getDeploymentAddresses } = require("../utils/readStatic")

module.exports = async function (taskArgs, hre) {
    const dao = await ethers.getContract("CrossChainDAO");
    const proposalid = taskArgs.proposalid;

    console.log(`[source] CrossChainDAOToken.address: ${dao.address}`);
    try {
        let spokeChainZero = await dao.spokeChains(0);
        console.log(`[source] CrossChainDAOToken.proposalSnapshot():`, spokeChainZero);
    }
    catch(e) {
        console.log(`[source] CrossChainDAOToken.spokeChains ERROR!`);
        console.log(`[source]`, e);
    }

}
