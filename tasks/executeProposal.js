module.exports = async function (taskArgs, hre) {
    // Change based on your hub chain
    if(hre.network.name != "moonbase" && hre.network.name != "dev-node") {
        console.log("Moonbase is the Hub chain! Proposals can currently only come from the hub chain.");
        return;
    }

    // Get local contract instance
    const dao = await ethers.getContract("CrossChainDAO")
    console.log(`[source] CrossChainDAO.address: ${dao.address}`);

    // Get local contract instance for the SimpleIncrementer
    const incrementer = await ethers.getContract("SimpleIncrementer");
    const incrementData = incrementer.interface.encodeFunctionData("increment", []);
    
    const targets = [incrementer.address];
    const values = [0];
    const callDatas = [incrementData];
    let descHash = ethers.utils.keccak256(ethers.utils.toUtf8Bytes(taskArgs.desc));

    // Delegate votes to task args
    let tx = await (await dao.execute(targets, values, callDatas, descHash)).wait()
    console.log(`✅ [${hre.network.name}] CrossChainDAO.execute([${incrementer.address}], [0], [${incrementData}], ${descHash})`)
    console.log(`...tx: ${tx.transactionHash}`);
}
