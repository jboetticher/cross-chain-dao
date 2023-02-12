npx hardhat deploy --tags CrossChainDAOToken --network moonbase
npx hardhat deploy --tags CrossChainDAOToken --network fantom-testnet
npx hardhat tokenSetTrustedRemote --network moonbase --target-network fantom-testnet
npx hardhat tokenSetTrustedRemote --network fantom-testnet --target-network moonbase
npx hardhat delegateVotes --network moonbase --acc 0x0394c0EdFcCA370B20622721985B577850B0eb75
npx hardhat delegateVotes --network fantom-testnet --acc 0x0394c0EdFcCA370B20622721985B577850B0eb75
npx hardhat deploy --tags CrossChainDAO --network moonbase
npx hardhat deploy --tags DAOSatellite --network fantom-testnet
npx hardhat daoSetTrustedRemote --network moonbase --target-network fantom-testnet
npx hardhat satelliteSetTrustedRemote --network fantom-testnet
npx hardhat deploy --tags SimpleIncrementer --network moonbase
npx hardhat newEmptyProposal --network moonbase --desc "This is a new proposal"