const CHAIN_ID = require("../constants/chainIds.json")
const { getDeploymentAddresses } = require("../utils/readStatic")

module.exports = async function (taskArgs, hre) {
    const dstChainId = CHAIN_ID[taskArgs.targetNetwork];
    const dstAddr = getDeploymentAddresses(taskArgs.targetNetwork)["CrossChainDAOToken"];

    // get local contract instance
    const TokenContract = await ethers.getContract("CrossChainDAOToken");
    console.log(`[source] CrossChainDAOToken.address: ${TokenContract.address}`);

    // Set trusted remote
    let tx = await (await TokenContract.setTrustedRemoteAddress(dstChainId, dstAddr)).wait()
    console.log(`✅ [${hre.network.name}] CrossChainDAOToken.setTrustedRemoteAddress( ${dstChainId}, ${dstAddr} )`)
    console.log(`...tx: ${tx.transactionHash}`);

    // Wait for transactions
    console.log("Waiting for confirmations...");
    await ethers.provider.waitForTransaction(
        tx.transactionHash, 2
    );

    console.log(`CrossChainDAOToken.getTrustedRemote( ${dstChainId} ): ${await TokenContract.getTrustedRemoteAddress(dstChainId)}`);
}
