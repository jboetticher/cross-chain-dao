const CHAIN_ID = require("../constants/chainIds.json")
const { getDeploymentAddresses } = require("../utils/readStatic")

module.exports = async function (taskArgs, hre) {
    const dstChainId = CHAIN_ID[taskArgs.targetNetwork]
    const dstPingPongAddr = getDeploymentAddresses(taskArgs.targetNetwork)["CrossChainDAOToken"]

    // get local contract instance
    const token = await ethers.getContract("CrossChainDAOToken")
    console.log(`[source] CrossChainDAOToken.address: ${token.address}`)

    let tx = await (await token.setTrustedRemote(dstChainId, dstPingPongAddr)).wait()
    console.log(`✅ [${hre.network.name}] CrossChainDAOToken.setTrustedRemote( ${dstChainId}, ${dstPingPongAddr} )`)
    console.log(`...tx: ${tx.transactionHash}`)
}
