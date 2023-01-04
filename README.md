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

You should also delegate votes to yourself so that you can do votes. This example uses the dev node's account,
but you should use whatever your account address is.  

```
npx hardhat delegateVotes --network dev-node --acc 0x6Be02d1d3665660d22FF9624b7BE0551ee1Ac91b
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

### SimpleIncrementer
This is an optional contract, but you can use it for testing out proposals and using the newEmptyProposal task.  

```
npx hardhat deploy --tags SimpleIncrementer --network moonbase
```

## Begin a Proposal & Vote
You can begin a proposal on the hub chain.  

```
npx hardhat newEmptyProposal --desc "My first cross-chain proposal!"
```

## Testing Smart Deployment on Dev Node
Deploy the cross chain DAO token:
```
npx hardhat deploy --network dev-node --tags CrossChainDAOToken
npx hardhat readTokenData --network dev-node --acc 0x6Be02d1d3665660d22FF9624b7BE0551ee1Ac91b
npx hardhat newEmptyProposal --network dev-node --desc "This is a proposal"
```

Can't do any cross-chain functionality, but at least you get to figure out if the deployment works.