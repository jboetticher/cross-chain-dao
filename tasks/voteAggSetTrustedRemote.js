const CHAIN_ID = require("../constants/chainIds.json")
const ENVIRONMENTS = require("../constants/environments.json")
const { getDeploymentAddresses } = require("../utils/readStatic")

// TODO: figure out if the tasks are set up correctly

module.exports = async function (taskArgs, hre) {

    // This destination is a constant. Must change if you want to deploy on a different hub. (But why would you? ;^>)
    const dstChainId = CHAIN_ID.moonbase
    const crossChainDAOAddr = getDeploymentAddresses("moonbase")["CrossChainDAO"]

    // get local contract instance
    const token = await ethers.getContract("VoteAggregator")
    console.log(`[source] VoteAggregator.address: ${token.address}`)

    let tx = await (await token.setTrustedRemote(dstChainId, crossChainDAOAddr)).wait()
    console.log(`✅ [${hre.network.name}] VoteAggregator.setTrustedRemote( ${dstChainId}, ${crossChainDAOAddr} )`)
    console.log(`...tx: ${tx.transactionHash}`)
}
