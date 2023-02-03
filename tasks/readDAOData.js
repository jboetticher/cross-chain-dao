const CHAIN_ID = require("../constants/chainIds.json")
const { getDeploymentAddresses } = require("../utils/readStatic")

module.exports = async function (taskArgs, hre) {
    const dao = await ethers.getContract("CrossChainDAO");

    console.log(`[source] CrossChainDAO.address: ${dao.address}`);
    let spokeChainZero;
    try {
        spokeChainZero = await dao.spokeChains(0);
        console.log(`[source] CrossChainDAO.spokeChains(0):`, spokeChainZero);
    }
    catch(e) {
        console.log(`[source] CrossChainDAO.spokeChains ERROR!`);
        console.log(`[source]`, e);
    }

    try {
        const chainToQuery = spokeChainZero ?? 0;
        let addr = await dao.getTrustedRemoteAddress(chainToQuery);
        console.log(`[source] CrossChainDAO.getTrustedRemoteAddress(${chainToQuery}):`, addr);
    }
    catch(e) {
        console.log(`[source] CrossChainDAO.getTrustedRemoteAddress ERROR!`);
        console.log(`[source]`, e);
    }

}
