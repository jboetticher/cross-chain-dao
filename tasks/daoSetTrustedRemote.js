const CHAIN_ID = require("../constants/chainIds.json")
const { getDeploymentAddresses } = require("../utils/readStatic")

module.exports = async function (taskArgs, hre) {
    const dstChainId = CHAIN_ID[taskArgs.targetNetwork]
    const dstAddr = getDeploymentAddresses(taskArgs.targetNetwork)["VoteAggregator"]

    // get local contract instance
    const dao = await ethers.getContract("CrossChainDAO");
    console.log(`[source] CrossChainDAO.address: ${dao.address}`)

    let tx = await (await dao.setTrustedRemoteAddress(dstChainId, dstAddr)).wait()
    console.log(`✅ [${hre.network.name}] CrossChainDAO.setTrustedRemoteAddress( ${dstChainId}, ${dstAddr} )`)
    console.log(`...tx: ${tx.transactionHash}`)
}
