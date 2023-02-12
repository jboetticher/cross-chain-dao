const CHAIN_ID = require("../constants/chainIds.json")
const ENVIRONMENTS = require("../constants/environments.json")
const { getDeploymentAddresses } = require("../utils/readStatic")

// TODO: figure out if the tasks are set up correctly

module.exports = async function (taskArgs, hre) {
    const proposalId = taskArgs.proposalid;

    // get local contract instance
    const aggregator = await ethers.getContract("DAOSatellite")
    console.log(`[source] DAOSatellite.address: ${aggregator.address}`)

    let proposalData = await aggregator.proposals(proposalId);
    console.log(`✅ [${hre.network.name}] DAOSatellite.proposals( ${proposalId} ):`);
    console.log(proposalData);

    try {
        const chainToQuery = CHAIN_ID.moonbase;
        let addr = await aggregator.getTrustedRemoteAddress(chainToQuery);
        console.log(`[source] DAOSatellite.getTrustedRemoteAddress(${chainToQuery}):`, addr);
    }
    catch(e) {
        console.log(`[source] DAOSatellite.getTrustedRemoteAddress ERROR!`);
        console.log(`[source]`, e);
    }
}
