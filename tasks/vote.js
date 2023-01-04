const CHAIN_ID = require("../constants/chainIds.json")
const { getDeploymentAddresses } = require("../utils/readStatic")

module.exports = async function (taskArgs, hre) {
    const { proposalId, support } = taskArgs;

    if (hre.network.name == "moonbase") {
        // Get local contract instance
        const dao = await ethers.getContract("CrossChainDAO")
        console.log(`[source] CrossChainDAO.address: ${dao.address}`);

        // Delegate votes to task args
        let tx = await (await token.propose([], [], [], taskArgs.desc)).wait()
        console.log(`✅ [${hre.network.name}] CrossChainDAO.castVote(0, 10)`)
        console.log(`...tx: ${tx.transactionHash}`);
    }
    else {
        // Get local contract instance
        const dao = await ethers.getContract("VoteAggregator")
        console.log(`[source] VoteAggregator.address: ${dao.address}`);

        // Delegate votes to task args
        let tx = await (await token.propose([], [], [], taskArgs.desc)).wait()
        console.log(`✅ [${hre.network.name}] VoteAggregator.propose(${taskArgs.acc})`)
        console.log(`...tx: ${tx.transactionHash}`);
    }
}
