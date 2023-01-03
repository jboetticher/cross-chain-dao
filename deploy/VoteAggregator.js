const LZ_ENDPOINTS = require("../constants/layerzeroEndpoints.json");
const CHAIN_IDS = require("../constants/chainIds.json");
const { getDeploymentAddresses } = require("../utils/readStatic");

module.exports = async function ({ deployments, getNamedAccounts }) {
    const { deploy, getNetworkName } = deployments
    const { deployer } = await getNamedAccounts()

    const voteToken = getDeploymentAddresses(hre.network.name)["CrossChainDAOToken"];
    const lzEndpointAddress = LZ_ENDPOINTS[hre.network.name]

    // NOTE:    change this based on the network you want to use, but since this tutorial is made for
    //          Moonbeam, the hub chain will always be Moonbeam / Moonbase Alpha
    const hubChain = CHAIN_IDS.moonbase;
    const args = [hubChain, lzEndpointAddress, voteToken];

    console.log(`Deploying VoteAggregator on ${getNetworkName()} with ${deployer}...`);

    try {
        const deployment = await deploy("VoteAggregator", {
            from: deployer,
            args,
            log: true,
            waitConfirmations: 1
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

module.exports.tags = ["VoteAggregator"]
