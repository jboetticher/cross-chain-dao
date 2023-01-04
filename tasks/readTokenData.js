const CHAIN_ID = require("../constants/chainIds.json")
const { getDeploymentAddresses } = require("../utils/readStatic")

module.exports = async function (taskArgs, hre) {
    const token = await ethers.getContract("CrossChainDAOToken");

    console.log(`[source] CrossChainDAOToken.address: ${token.address}`);
    try {
        let votes = await token.getVotes(taskArgs.acc);
        console.log(`[source] CrossChainDAOToken.getVotes(${taskArgs.acc}):`, votes);
    }
    catch(e) {
        console.log(`[source] CrossChainDAOToken.getVotes ERROR!`);
        console.log(`[source]`, e);
    }

    try {
        let checkpoints = await token.getPastTotalSupply(0);
        console.log(`[source] CrossChainDAOToken.getPastTotalSupply(0):`, checkpoints);
    }
    catch(e) {
        console.log(`[source] CrossChainDAOToken.getPastTotalSupply ERROR!`);
        console.log(`[source]`, e);
    }

    try {
        let tokens = await token.balanceOf(taskArgs.acc);
        console.log(`[source] CrossChainDAOToken.balanceOf(${taskArgs.acc}):`, tokens);
    }
    catch(e) {
        console.log(`[source] CrossChainDAOToken.balanceOf ERROR!`);
        console.log(`[source]`, e);
    }

    // totalSupply makes sense! But why doesn't the user get vote power on the original mint?
    try {
        let totalSupply = await token.totalSupply();
        console.log(`[source] CrossChainDAOToken.totalSupply():`, totalSupply);
    }
    catch(e) {
        console.log(`[source] CrossChainDAOToken.totalSupply ERROR!`);
        console.log(`[source]`, e);
    }
}
