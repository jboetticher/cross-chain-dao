// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/governance/Governor.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorSettings.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorCountingSimple.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotes.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotesQuorumFraction.sol";

/* 
~~~~~~~ ON OPENZEPPELIN ~~~~~~
Code is generated from: https://www.openzeppelin.com/contracts
OpenZeppelin is a widely used smart contract framework that has significatly shaped standards in solidity smart contracts.
This smart contract relies on its governance and ERC-20 smart contracts for hub-chain DAO actions. The governance smart 
contracts from OpenZeppelin are also based off of Compound's DAO smart contracts.

~~~~~~~~ ON TIMELOCKS ~~~~~~~~
Notice that it doesn't have a Timelock. A timelock is used to delay the execution of a proposal after it has been completed
in case actors who disagree with the proposal want to exit the ecosystem before it is implemented. This is a common practice
and can be seen in giant governance schemes like Polkadot. However, this will not be included for this example for 
simplicity's sake.
*/

// I think the current gameplan is to make our own IVotes smart contract

contract CrossChainDAO is Governor, GovernorSettings, GovernorCountingSimple, GovernorVotes, GovernorVotesQuorumFraction {
    constructor(IVotes _token)
        Governor("Moonbeam Example Cross Chain DAO")
        GovernorSettings(1 /* 1 block */, 5 /* 5 block */, 0)
        GovernorVotes(_token)
        GovernorVotesQuorumFraction(4)
    {}

    // The following functions are overrides required by Solidity.

    function votingDelay()
        public
        view
        override(IGovernor, GovernorSettings)
        returns (uint256)
    {
        return super.votingDelay();
    }

    function votingPeriod()
        public
        view
        override(IGovernor, GovernorSettings)
        returns (uint256)
    {
        return super.votingPeriod();
    }

    function quorum(uint256 blockNumber)
        public
        view
        override(IGovernor, GovernorVotesQuorumFraction)
        returns (uint256)
    {
        return super.quorum(blockNumber);
    }

    function proposalThreshold()
        public
        view
        override(Governor, GovernorSettings)
        returns (uint256)
    {
        return super.proposalThreshold();
    }
}
