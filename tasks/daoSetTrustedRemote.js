const CHAIN_ID = require("../constants/chainIds.json")
const { getDeploymentAddresses } = require("../utils/readStatic")

module.exports = async function (taskArgs, hre) {
    const dstChainId = CHAIN_ID[taskArgs.targetNetwork]
    const dstAddr = getDeploymentAddresses(taskArgs.targetNetwork)["VoteAggregator"]

    // get local contract instance
    const token = await ethers.getContract("CrossChainDAO")
    console.log(`[source] CrossChainDAO.address: ${token.address}`)

    let tx = await (await token.setTrustedRemote(dstChainId, dstAddr)).wait()
    console.log(`✅ [${hre.network.name}] CrossChainDAO.setTrustedRemote( ${dstChainId}, ${dstAddr} )`)
    console.log(`...tx: ${tx.transactionHash}`)
}
