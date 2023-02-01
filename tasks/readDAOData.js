const CHAIN_ID = require("../constants/chainIds.json")
const { getDeploymentAddresses } = require("../utils/readStatic")

module.exports = async function (taskArgs, hre) {
    const dao = await ethers.getContract("CrossChainDAO");

    console.log(`[source] CrossChainDAOToken.address: ${dao.address}`);
    let spokeChainZero;
    try {
        spokeChainZero = await dao.spokeChains(0);
        console.log(`[source] CrossChainDAOToken.spokeChains(0):`, spokeChainZero);
    }
    catch(e) {
        console.log(`[source] CrossChainDAOToken.spokeChains ERROR!`);
        console.log(`[source]`, e);
    }

    console.log(`[source] CrossChainDAOToken.getTrustedRemoteAddress: ${dao.address}`);
    try {
        const chainToQuery = spokeChainZero ?? 0;
        let addr = await dao.getTrustedRemoteAddress(chainToQuery);
        console.log(`[source] CrossChainDAOToken.getTrustedRemoteAddress(${chainToQuery}):`, addr);
    }
    catch(e) {
        console.log(`[source] CrossChainDAOToken.getTrustedRemoteAddress ERROR!`);
        console.log(`[source]`, e);
    }

}
