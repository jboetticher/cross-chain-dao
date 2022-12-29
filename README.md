# Example Cross-Chain DAO
This is an example of a cross-chain DAO. It follows a hub-and-spoke model.  
The `CrossChainDAO.sol` file is the main logic. The `DAOSatellite.sol` contract communicates across chains with the `CrossChainDAO.sol` smart contract.

## Deployment
```
npx hardhat --network moonbase deploy --tags CrossChainDAOToken
```