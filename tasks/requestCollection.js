const CHAIN_ID = require("../constants/chainIds.json")
const { getDeploymentAddresses } = require("../utils/readStatic")

module.exports = async function (taskArgs, hre) {
    // Change based on your hub chain
    if(hre.network.name != "moonbase" && hre.network.name != "dev-node") {
        console.log("Moonbase is the Hub chain! Colletion requests can currently only originate from the hub chain.");
        return;
    }

    // Get local contract instance
    const dao = await ethers.getContract("CrossChainDAO")
    console.log(`[source] CrossChainDAO.address: ${dao.address}`);


    // Request collection
    let tx = await (await dao.requestCollections(taskArgs.proposalid, { value: "10000000000000000" })).wait()
    console.log(`✅ [${hre.network.name}] CrossChainDAO.requestCollections(${taskArgs.proposalid})`)
    console.log(`...tx: ${tx.transactionHash}`);
}
