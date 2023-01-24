const CHAIN_ID = require("../constants/chainIds.json")
const { getDeploymentAddresses } = require("../utils/readStatic")

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

    // Delegate votes to task args
    let tx = await (await dao.crossChainPropose(targets, values, callDatas, taskArgs.desc, { value: "10000000000000000" })).wait()
    console.log(`✅ [${hre.network.name}] CrossChainDAO.crossChainPropose([${incrementer.address}], [0], [${incrementData}], ${taskArgs.desc})`)
    console.log(`...tx: ${tx.transactionHash}`);

    // Print out the proposal ID
    const proposalCreatedEventData = tx.events.find(event => event.event === 'ProposalCreated').data;
    const proposalCreatedEventDecoded = ethers.utils.defaultAbiCoder.decode(
        ["uint256", "address", "address[]", "uint256[]", "string[]", "bytes[]", "uint256", "uint256", "string"], 
        proposalCreatedEventData
    );
    console.log(`[${hre.network.name}] CrossChainDAO.crossChainPropose => proposeId: ${proposalCreatedEventDecoded[0].toString()}`)
    //console.log(proposalCreatedEventDecoded);
}
