const LZ_ENDPOINTS = require("../constants/layerzeroEndpoints.json")

module.exports = async function ({ deployments, getNamedAccounts }) {
    const { deploy, getNetworkName } = deployments
    const { deployer } = await getNamedAccounts()

    const lzEndpointAddress = LZ_ENDPOINTS[hre.network.name]
    const thousandTokens = hre.ethers.utils.parseEther("1000");
    const args = [thousandTokens, lzEndpointAddress];

    console.log(`Deploying CrossChainDAOToken on ${getNetworkName()} with ${deployer}...`);

    try {
        const deployment = await deploy("CrossChainDAOToken", {
            from: deployer,
            args,
            log: true,
            waitConfirmations: 1,
        });


        // Wait for transactions
        console.log("Waiting for confirmations...");
        await ethers.provider.waitForTransaction(
            deployment.deployTransaction.hash, 2
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

module.exports.tags = ["CrossChainDAOToken"]
