
module.exports = async function (taskArgs, hre) {
    const { proposalid, support } = taskArgs;

    if (hre.network.name == "moonbase" || hre.network.name == "dev-node") {
        // Get local contract instance
        const dao = await ethers.getContract("CrossChainDAO")
        console.log(`[source] CrossChainDAO.address: ${dao.address}`);

        // Delegate votes to task args
        let tx = await (await dao.castVote(proposalid, support)).wait()
        console.log(`✅ [${hre.network.name}] CrossChainDAO.castVote(${proposalid}, ${support})`)
        console.log(`...tx: ${tx.transactionHash}`);
    }
    else {
        // Get local contract instance
        const dao = await ethers.getContract("VoteAggregator")
        console.log(`[source] VoteAggregator.address: ${dao.address}`);

        // Delegate votes to task args
        let tx = await (await token.castVote(proposalid, support)).wait()
        console.log(`✅ [${hre.network.name}] VoteAggregator.castVote(${proposalid}, ${support})`)
        console.log(`...tx: ${tx.transactionHash}`);
    }
}
