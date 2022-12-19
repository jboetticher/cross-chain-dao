// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/governance/Governor.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorSettings.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorCountingSimple.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotes.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotesQuorumFraction.sol";
import "./LayerZero/lzApp/NonblockingLzApp.sol";

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

contract CrossChainDAO is
    Governor,
    GovernorSettings,
    GovernorCountingSimple,
    GovernorVotes,
    GovernorVotesQuorumFraction,
    NonblockingLzApp
{
    constructor(IVotes _token, address lzEndpoint)
        Governor("Moonbeam Example Cross Chain DAO")
        GovernorSettings(
            1, /* 1 block voting delay */
            5, /* 5 block voting period */
            0 /* 0 block proposal threshold */
        )
        GovernorVotes(_token)
        GovernorVotesQuorumFraction(4)
        NonblockingLzApp(lzEndpoint)
    {}

    function _nonblockingLzReceive(
        uint16 _srcChainId,
        bytes memory _srcAddress,
        uint64 _nonce,
        bytes memory _payload
    ) internal override {
        // Decode from the bytes if they are voting. You probably don't have to implement anything else for the tutorial
        // Some options are: proposal, vote, vote with reason, vote with reason and params, cancel, etc...
    }

    // The following functions are overrides required by Solidity.

    /**
     * @dev Delay, in number of block, between the proposal is created and the vote starts. This can be increassed to
     * leave time for users to buy voting power, or delegate it, before the voting of a proposal starts.
     */
    function votingDelay()
        public
        view
        override(IGovernor, GovernorSettings)
        returns (uint256)
    {
        return super.votingDelay();
    }

    /**
     * @dev Delay, in number of blocks, between the vote start and vote ends.
     *
     * NOTE: The {votingDelay} can delay the start of the vote. This must be considered when setting the voting
     * duration compared to the voting delay.
     */
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
