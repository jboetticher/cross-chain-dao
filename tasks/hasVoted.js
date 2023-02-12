
module.exports = async function (taskArgs, hre) {
    const { proposalid, acc } = taskArgs;

    if (hre.network.name == "moonbase" || hre.network.name == "dev-node") {
        // Get local contract instance
        const dao = await ethers.getContract("CrossChainDAO")
        console.log(`[source] CrossChainDAO.address: ${dao.address}`);

        let hasVoted = await dao.hasVoted(proposalid, acc);
        console.log(`✅ [${hre.network.name}] CrossChainDAO.hasVoted(${proposalid}, ${acc}): ${hasVoted}`)
    }
    else {
        // Get local contract instance
        const dao = await ethers.getContract("DAOSatellite")
        console.log(`[source] DAOSatellite.address: ${dao.address}`);

        // Delegate votes to task args
        let hasVoted = await dao.hasVoted(proposalid, acc);
        console.log(`✅ [${hre.network.name}] CrossChainDAO.hasVoted(${proposalid}, ${acc}): ${hasVoted}`)
    }
}
