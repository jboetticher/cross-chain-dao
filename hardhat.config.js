require("@nomicfoundation/hardhat-toolbox");
const { privateKey } = require('./secrets.json');

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.9",
  networks: {
    ropsten: {
      url: 'https://eth-ropsten.gateway.pokt.network/v1/lb/62a0c8ff87017d0039b81bb6',
      chainId: 3,
      accounts: [privateKey]
    },
    moonbase: {
      url: 'https://rpc.api.moonbase.moonbeam.network',
      chainId: 1287, // 0x507 in hex,
      accounts: [privateKey]
    },
    mumbai: {
      url: 'https://matic-mumbai.chainstacklabs.com',
      chainId: 80001,
      accounts: [privateKey]
    },
    fuji: {
      url: 'https://api.avax-test.network/ext/bc/C/rpc',
      chainId: 43113,
      accounts: [privateKey]
    },
    fantom: {
      url: 'https://rpc.testnet.fantom.network/',
      chainId: 4002,
      accounts: [privateKey]
    }
  },
};
