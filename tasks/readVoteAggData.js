const CHAIN_ID = require("../constants/chainIds.json")
const ENVIRONMENTS = require("../constants/environments.json")
const { getDeploymentAddresses } = require("../utils/readStatic")

// TODO: figure out if the tasks are set up correctly

module.exports = async function (taskArgs, hre) {
    const proposalId = taskArgs.proposalid;

    // get local contract instance
    const aggregator = await ethers.getContract("VoteAggregator")
    console.log(`[source] VoteAggregator.address: ${aggregator.address}`)

    let proposalData = await aggregator.proposals(proposalId);
    console.log(`✅ [${hre.network.name}] VoteAggregator.proposals( ${proposalId} ):`);
    console.log(proposalData);
}
