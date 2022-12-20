// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/governance/Governor.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorSettings.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorCountingSimple.sol";
import "./CrossChainGovernorVotes.sol";
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
    CrossChainGovernorVotes,
    CrossChainGovernorVotesQuorumFraction,
    NonblockingLzApp
{
    constructor(
        IVotes _token,
        address lzEndpoint,
        uint16[] memory _spokeChains
    )
        Governor("Moonbeam Example Cross Chain DAO")
        GovernorSettings(
            1, /* 1 block voting delay */
            5, /* 5 block voting period */
            0 /* 0 block proposal threshold */
        )
        CrossChainGovernorVotes(_token)
        CrossChainGovernorVotesQuorumFraction(4)
        NonblockingLzApp(lzEndpoint)
    {
        spokeChains = _spokeChains;
    }

    struct ExternalVotingData {
        uint256 quorum;
        uint256 voteWeight;
        bool initialized;
    }

    // The lz-chain IDs that the DAO expects to receive data from during the collection phase
    uint16[] spokeChains;

    // Whether or not the DAO finished the collection phase. It would be more efficient to add Collection as a status
    // in the Governor interface, but that would require editing the source file. It is a bit out of scope to completely
    // refactor the OpenZeppelin governance contract for cross-chain action!
    mapping(uint256 => bool) collectionFinished;
    mapping(uint256 => bool) collectionStarted;

    // Maps to a list of external voting
    mapping(uint256 => mapping(uint16 => ExternalVotingData)) voting;

    // How many blocks to wait until the collection phase is marked as finished, regardless of data received.
    uint16 collectionPhaseWaitingPeriod;

    function _nonblockingLzReceive(
        uint16 _srcChainId,
        bytes memory /*_srcAddress*/,
        uint64 /*_nonce*/,
        bytes memory _payload
    ) internal override {
        (uint16 option, bytes memory payload) = abi.decode(_payload, (uint16, bytes));

        // Some options for cross-chain actions are: propose, vote, vote with reason, vote with reason and params, cancel, etc...
        if(option == 0) {
            onReceiveExternalVotingData(_srcChainId, payload);
        }
        else if(option == 1) {
            // TODO: Feel free to put your own cross-chain actions...
        }
        else {
            // ...
        }
    }

    function onReceiveExternalVotingData(uint16 _srcChainId, bytes memory payload) internal virtual {

    }

    // Ensures that there is no execution if the collection phase is unfinished
    function _beforeExecute(
        uint256 proposalId,
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) internal override {
        require(
            collectionFinished[proposalId],
            "Collection phase for this proposal is unfinished!"
        );
        super._beforeExecute(
            proposalId,
            targets,
            values,
            calldatas,
            descriptionHash
        );
    }

    // Marks a collection phase as true if all of the
    function finishCollectionPhase(uint256 proposalId) external {
        bool phaseFinished = true;
        for (uint16 i = 0; i < spokeChains.length && phaseFinished; i++) {
            phaseFinished = voting[proposalId][spokeChains[i]].initialized;
        }
        if (phaseFinished) {
            collectionFinished[proposalId] = true;
        }
    }

    function requestCollections(uint256 proposalId) public payable {
        require(
            collectionStarted[proposalId],
            "Collection phase for this proposal has already finished!"
        );

        // Sends an empty message to each of the aggregators. If they receive a message at all,
        // it is their cue to send data back
        for (uint16 i = 0; i < spokeChains.length; i++) {
            bytes memory payload = abi.encode(0);
            _lzSend({
                _dstChainId: spokeChains[i],
                _payload: payload,
                _refundAddress: payable(msg.sender),
                _zroPaymentAddress: address(0x0),
                _adapterParams: bytes(""),
                _nativeFee: 0.1 ether
            });
        }
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
        override(IGovernor, CrossChainGovernorVotesQuorumFraction)
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
