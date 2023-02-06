// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/governance/Governor.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorSettings.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorCountingSimple.sol";
import "./LayerZero/lzApp/NonblockingLzApp.sol";
import "./CrossChain/CrossChainGovernorVotes.sol";
import "./CrossChain/CrossChainGovernorCountingSimple.sol";

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

~~~~~~~~~~ ON QUORUM ~~~~~~~~~
Typically, an OpenZeppelin Governor's quorum can be altered by democracy, but for simplicity's sake, the quorum has been 
reduced to a static value of 1 ether. This means that a single voter holding a single token can vote for a proposal and 
allow it to pass, even if there are 100k tokens in supply. Please view OpenZeppelin's GovernorVotesQuorumFraction smart 
contract if interested.

*/

// TODO: figure out why the contracts compiled into something so massive

contract CrossChainDAO is
    Governor,
    GovernorSettings,
    CrossChainGovernorCountingSimple,
    CrossChainGovernorVotes,
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
            30, /* 30 block voting period */
            0 /* 0 block proposal threshold */
        )
        CrossChainGovernorVotes(_token)
        NonblockingLzApp(lzEndpoint)
    {
        spokeChains = _spokeChains;
    }

    event LzAppToSendThisPayload(bytes);

    // How many blocks to wait until the collection phase is marked as finished, regardless of data received.
    uint16 collectionPhaseWaitingPeriod;

    function _nonblockingLzReceive(
        uint16 _srcChainId,
        bytes memory, /*_srcAddress*/
        uint64, /*_nonce*/
        bytes memory _payload
    ) internal override {
        (uint256 option, bytes memory payload) = abi.decode(
            _payload,
            (uint16, bytes)
        );

        // Some options for cross-chain actions are: propose, vote, vote with reason, vote with reason and params, cancel, etc...
        if (option == 0) {
            onReceiveExternalVotingData(_srcChainId, payload);
        } else if (option == 1) {
            // TODO: Feel free to put your own cross-chain actions (propose, execute, etc)...
        } else {
            // ...
        }
    }

    function onReceiveExternalVotingData(
        uint16 _srcChainId,
        bytes memory payload
    ) internal virtual {
        (
            uint256 _proposalId,
            uint256 _pro,
            uint256 _against,
            uint256 _abstain
        ) = abi.decode(payload, (uint256, uint256, uint256, uint256));
        if (spokeVotes[_proposalId][_srcChainId].initialized) {
            revert("Already initialized!");
        } else {
            spokeVotes[_proposalId][_srcChainId] = SpokeProposalVote(
                _pro,
                _against,
                _abstain,
                true
            );
        }
    }

    // Ensures that there is no execution if the collection phase is unfinished
    function _beforeExecute(
        uint256 proposalId,
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) internal override {
        finishCollectionPhase(proposalId);

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

    // Requests the voting data from all of the spoke chains
    function requestCollections(uint256 proposalId) public payable {
        require(
            block.number > proposalDeadline(proposalId),
            "Cannot request for vote collection until after the vote period is over!"
        );
        require(
            !collectionStarted[proposalId],
            "Collection phase for this proposal has already finished!"
        );

        collectionStarted[proposalId] = true;

        // Sends an empty message to each of the aggregators. If they receive a message at all,
        // it is their cue to send data back
        uint256 crossChainFee = msg.value / spokeChains.length;
        for (uint16 i = 0; i < spokeChains.length; i++) {
            bytes memory payload = abi.encode(1, abi.encode(proposalId));
            _lzSend({
                _dstChainId: spokeChains[i],
                _payload: payload,
                _refundAddress: payable(address(this)),
                _zroPaymentAddress: address(0x0),
                _adapterParams: bytes(""),
                _nativeFee: crossChainFee
            });
        }
    }

    // Marks a collection phase as true if all of the satellite chains have sent a cross-chain message back
    function finishCollectionPhase(uint256 proposalId) public {
        bool phaseFinished = true;
        for (uint16 i = 0; i < spokeChains.length && phaseFinished; i++) {
            phaseFinished =
                phaseFinished &&
                spokeVotes[proposalId][spokeChains[i]].initialized;
        }

        collectionFinished[proposalId] = phaseFinished;
    }

    // Proper proposal function
    function crossChainPropose(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        string memory description
    ) public payable virtual returns (uint256) {
        uint256 proposalId = super.propose(
            targets,
            values,
            calldatas,
            description
        );

        // Now send the proposal to all of the other chains
        // NOTE: You could also provide the time end, but that should be done with a timestamp as well
        if (spokeChains.length > 0) {
            uint256 crossChainFee = msg.value / spokeChains.length;
            for (uint16 i = 0; i < spokeChains.length; i++) {
                bytes memory payload = abi.encode(
                    0,
                    abi.encode(proposalId, block.timestamp)
                );

                emit LzAppToSendThisPayload(payload);
                _lzSend({
                    _dstChainId: spokeChains[i],
                    _payload: payload,
                    _refundAddress: payable(address(this)),
                    _zroPaymentAddress: address(0x0),
                    _adapterParams: bytes(""),
                    _nativeFee: crossChainFee
                });
            }
        }

        return proposalId;
    }

    // Revert the typical propose because it doesn't allow for "payable"
    function propose(
        address[] memory,
        uint256[] memory,
        bytes[] memory,
        string memory
    ) public virtual override returns (uint256) {
        revert("Use cross-chain propose!");
    }

    // =========================================================================================================
    //                        The following functions are overrides required by Solidity
    // =========================================================================================================

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

    // Delay, in number of blocks, between the vote start and vote ends
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
        override(CrossChainGovernorCountingSimple, IGovernor)
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
