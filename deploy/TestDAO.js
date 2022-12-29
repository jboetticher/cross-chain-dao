const LZ_ENDPOINTS = require("../constants/layerzeroEndpoints.json");
const CHAIN_IDS = require("../constants/chainIds.json");

module.exports = async function ({ deployments, getNamedAccounts }) {
    const { deploy, getNetworkName } = deployments
    const { deployer } = await getNamedAccounts()

    // TODO: get the token if it's already been deployed on the current chain. Currently placeholder
    const placeholder = "0x0394c0EdFcCA370B20622721985B577850B0eb75";
    const lzEndpointAddress = LZ_ENDPOINTS[hre.network.name]

    // NOTE:    change this based on the network you want to use, but since this tutorial is made for
    //          Moonbeam, the hub chain will always be Moonbeam / Moonbase Alpha
    const hubChain = CHAIN_IDS.moonbase;



    const args = [placeholder];

    console.log(`Deploying TestDAO on ${getNetworkName()} with ${deployer}...`);

    try {
        const deployment = await deploy("TestDAO", {
            from: deployer,
            args,
            log: true,
            waitConfirmations: 1
        });
        //console.log(deployment);

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

module.exports.tags = ["TestDAO"]
