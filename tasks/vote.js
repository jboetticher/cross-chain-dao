
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
        const dao = await ethers.getContract("DAOSatellite")
        console.log(`[source] DAOSatellite.address: ${dao.address}`);

        // Delegate votes to task args
        let tx = await (await dao.castVote(proposalid, support)).wait()
        console.log(`✅ [${hre.network.name}] DAOSatellite.castVote(${proposalid}, ${support})`)
        console.log(`...tx: ${tx.transactionHash}`);
    }
}
