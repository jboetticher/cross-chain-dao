const CHAIN_ID = require("../constants/chainIds.json")
const { getDeploymentAddresses } = require("../utils/readStatic")

module.exports = async function (taskArgs, hre) {
    // get local contract instance
    const token = await ethers.getContract("CrossChainDAOToken")
    console.log(`[source] CrossChainDAOToken.address: ${token.address}`);

    // Delegate votes to task args
    let tx = await (await token.delegate(taskArgs.acc)).wait()
    console.log(`✅ [${hre.network.name}] CrossChainDAO.setTrustedRemote(${taskArgs.acc})`)
    console.log(`...tx: ${tx.transactionHash}`);
}
