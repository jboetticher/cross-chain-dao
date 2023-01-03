# Example Cross-Chain DAO
This is an example of a cross-chain DAO. It follows a hub-and-spoke model.  
The `CrossChainDAO.sol` file is the main logic. The `DAOSatellite.sol` contract communicates across chains with the `CrossChainDAO.sol` smart contract.

## Deployment
The following docs will be for deploying to hub chain Moonbase Alpha and spoke chain Fantom.

### CrossChainDAOToken
First thing to deploy is the CrossChainDAOToken, which determines the votes on each chain.  

```
npx hardhat deploy --tags CrossChainDAOToken --network moonbase
npx hardhat deploy --tags CrossChainDAOToken --network fantom-testnet
```

Then you set them as trusted.

```
npx hardhat tokenSetTrustedRemote --network moonbase --target-network fantom-testnet
npx hardhat tokenSetTrustedRemote --network fantom-testnet --target-network moonbase
```

### CrossChainDAO
This only needs to be deployed once, since it expects to communicate with VoteAggregator contracts.  

```
npx hardhat deploy --tags CrossChainDAO --network moonbase
```

The setting trusted contracts section happens after deploying the VoteAggregator contracts.  

### VoteAggregator
Now you ought to deploy the VoteAggregator smart contracts on the hub chains.  

```
npx hardhat deploy --tags VoteAggregator --network fantom-testnet
```

Now both the DAO and the satellite VoteAggregators have to have their remote addresses trusted.  

```
npx hardhat daoSetTrustedRemote --network moonbase --target-network fantom-testnet
npx hardhat voteAggSetTrustedRemote --network fantom-testnet
```