# Example Cross-Chain DAO
This is an example of a cross-chain DAO. It follows a hub-and-spoke model.  
The `CrossChainDAO.sol` file is the main logic. The `VotesAggregator.sol` contract communicates across chains with the `CrossChainDAO.sol` smart contract.  

## Design
The original process of a DAO (OpenZeppelin contract inspired by Compound) would have the following steps:  
1. Propose
2. Voting Period
3. Execution  

The cross-chain DAO would have these steps:  
1. Propose
2. Voting Period
3. Collection Period
4. Execution

When the proposal is initiated, it uses a past snapshot to determine which account has so many votes. During the voting period, accounts are able to cast yay or nay for a vote. During execution, once the voting period is finished, if the vote succeeds, anyone can execute the proposal.  

The collection period is unique to the cross-chain DAO because it is when all of the votes from all of the chains are collected and processed on the hub chain to determine which side won.  

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
npx hardhat delegateVotes --network -node --acc 0x6Be02d1d3665660d22FF9624b7BE0551ee1Ac91b
```

### CrossChainDAO
This only needs to be deployed once, since it expects to communicate with DAOSatellite contracts.  

```
npx hardhat deploy --tags CrossChainDAO --network moonbase
```

The setting trusted contracts section happens after deploying the DAOSatellite contracts.  

### DAOSatellite
Now you ought to deploy the DAOSatellite smart contracts on the hub chains.  

```
npx hardhat deploy --tags DAOSatellite --network fantom-testnet
```

Now both the DAO and the satellite DAOSatellites have to have their remote addresses trusted.  

```
npx hardhat daoSetTrustedRemote --network moonbase --target-network fantom-testnet
npx hardhat voteAggSetTrustedRemote --network fantom-testnet
```

### SimpleIncrementer
This is an optional contract, but you can use it for testing out proposals and using the newEmptyProposal task.  

```
npx hardhat deploy --tags SimpleIncrementer --network moonbase
```

## Begin a Proposal
You can begin a proposal on the hub chain that increments a number using the SimpleIncrementer.  

```
npx hardhat newEmptyProposal --network moonbase --desc "My first cross-chain proposal"
```

## Vote on the Proposal
If you've just deployed, you should see the proposeId in the console. You can cast a vote with the following command:  

```
npx hardhat vote --network dev-node --support 1 --proposalid {INSERT_PROPOSAL_ID} 
```

0 is AGAINST, 1 is FOR, 2 is ABSTAIN.

## Testing Smart Deployment on Dev Node
Deploy the cross chain DAO token:
```
npx hardhat deploy --network dev-node --tags CrossChainDAOToken
npx hardhat readTokenData --network dev-node --acc 0x6Be02d1d3665660d22FF9624b7BE0551ee1Ac91b
npx hardhat newEmptyProposal --network dev-node --desc "This is a proposal"
```

Can't do any cross-chain functionality, but at least you get to figure out if the deployment works.