const LZ_ENDPOINTS = require("../constants/layerzeroEndpoints.json");
const CHAIN_IDS = require("../constants/chainIds.json");
const { getDeploymentAddresses } = require("../utils/readStatic");

module.exports = async function ({ deployments, getNamedAccounts }) {
    const { deploy, getNetworkName } = deployments
    const { deployer } = await getNamedAccounts()

    const tokenAddr = getDeploymentAddresses(hre.network.name)["CrossChainDAOToken"];
    const lzEndpointAddress = LZ_ENDPOINTS[hre.network.name]

    if(tokenAddr == null) {
        throw new Error("CrossChainDAOToken has not been deployed yet!");
    }

    // NOTE:    change this based on the network you want to use, but since this tutorial is made for
    //          Moonbeam, the hub chain will always be Moonbeam / Moonbase Alpha
    const spokeChains = [ CHAIN_IDS["fantom-testnet"] ]// getNetworkName() == "moonbase" ? [ CHAIN_IDS["fantom-testnet"] ] : [];
    const args = [tokenAddr, lzEndpointAddress, spokeChains];

    console.log(`Deploying CrossChainDAO on ${getNetworkName()} with ${deployer}...`);

    try {
        const deployment = await deploy("CrossChainDAO", {
            from: deployer,
            args,
            log: true,
            waitConfirmations: 1,
        });


        // Wait for transactions
        console.log("Waiting for confirmations...");
        await ethers.provider.waitForTransaction(
            deployment.transactionHash, 2
        );

        // Attempt to verify
        await hre.run("verify:verify", {
            address: deployment.address,
            constructorArguments: args,
        });
        console.log("Verification should be complete.");
    }
    catch (err) {
        console.log(err);
        console.log(err.message);
    }
}

module.exports.tags = ["CrossChainDAO"]
