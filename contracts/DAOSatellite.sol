// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@layerzerolabs/solidity-examples/contracts/lzApp/NonblockingLzApp.sol";
import "@openzeppelin/contracts/utils/Timers.sol";
import "@openzeppelin/contracts/utils/Checkpoints.sol";
import "@openzeppelin/contracts/governance/utils/IVotes.sol";

// setTrustedRemote: the only contract that should be trusted is the DAO on the hub chain


// This contract doesn't adhere to a lot of the interfaces provided by IGovernor and its modules
contract DAOSatellite is NonblockingLzApp {
    using Checkpoints for Checkpoints.History;

    event RemoteProposalReceived(uint256 id, uint256 localVoteStart);
    event SendingQuorumDataToHub(uint256 id, uint256 forVotes, uint256 againstVotes, uint256 abstainVotes);

    error VotingHasClosedOnThisChain();

    constructor(
        uint16 _hubChain,
        address _endpoint,
        IVotes _token,
        uint _targetSecondsPerBlock
    ) NonblockingLzApp(_endpoint) payable {
        hubChain = _hubChain;
        token = _token;
        targetSecondsPerBlock = _targetSecondsPerBlock;
    }

    uint16 public immutable hubChain;
    IVotes public immutable token;
    uint256 public immutable targetSecondsPerBlock;
    mapping(uint256 => RemoteProposal) public proposals;
    mapping(uint256 => ProposalVote) public proposalVotes;

    struct RemoteProposal {
        // Blocks provided by the hub chain as to when the local votes should start/finish.
        // This guides the algorithm for determining what the right vote weights from the CrossChainToken should be.
        // NOTE:    This is an alright solution given the assumption that there is no downtime on any chain.
        //          Will need a proper solution still to fix in case of such a scenario
        uint256 localVoteStart; // You could also use uint64 in the Timers library, like OpenZeppelin uses
        bool voteFinished;
        // bool canceled; TODO: implement cancelation on your own
    }

    function castVote(uint256 proposalId, uint8 support)
        public
        virtual
        returns (uint256 balance)
    {
        // Get the vote weights from the local CrossChainToken implementation
        // Check them against the local block boundaries. If the boundaries are closed, then revert
        // Doesn't need to send a vote
        RemoteProposal storage proposal = proposals[proposalId];
        require(
            !proposal.voteFinished,
            "DAOSatellite: vote not currently active"
        );
        require(
            isProposal(proposalId), 
            "DAOSatellite: not a started vote"
        );

        uint256 weight = token.getPastVotes(msg.sender, proposal.localVoteStart);
        _countVote(proposalId, msg.sender, support, weight);

        // You could add event emitters here like in the original implementation

        return weight;
    }

    function isProposal(uint256 proposalId) view public returns(bool) {
        return proposals[proposalId].localVoteStart != 0;
    }

    function _nonblockingLzReceive(
        uint16 _srcChainId,
        bytes memory /* _srcAddress */,
        uint64 /* _nonce */,
        bytes memory _payload
    ) internal override {
        require(_srcChainId == hubChain, "Only messages from the hub chain can be received!");

        uint16 option;
        assembly {
            option := mload(add(_payload, 32))
        }

        // Do 1 of 2 things:
        // 0. Begin a proposal on the local chain, with local block times
        if (option == 0) {
            (, uint256 proposalId, uint256 proposalStart) = abi.decode(_payload, (uint16, uint256, uint256));
            require(!isProposal(proposalId), "Proposal ID must be unique.");

            // Snapshot cut-off estimation
            // Estimates what block with the original timestamp would have been on this local chain
            // There are security issues, since this estimation is less accurate over time, but this is more simple than an oracle.
            // One issue includes the ability to vote multiple times on multiple chains in order of increasing cut-off, if they knew beforehand that
            // a proposal would be made
            uint256 cutOffBlockEstimation = 0;
            if(proposalStart < block.timestamp) {
                uint256 blockAdjustment = (block.timestamp - proposalStart) / targetSecondsPerBlock;
                if(blockAdjustment < block.number) {
                    cutOffBlockEstimation = block.number - blockAdjustment;
                }
                else {
                    cutOffBlockEstimation = block.number;
                }
            }
            else {
                cutOffBlockEstimation = block.number;
            }

            proposals[proposalId] = RemoteProposal(cutOffBlockEstimation, false);
            emit RemoteProposalReceived(proposalId, cutOffBlockEstimation);
        }
        // 1. Send vote results back to the local chain
        else if (option == 1) {
            (, uint256 proposalId) = abi.decode(_payload, (uint16, uint256));
            ProposalVote storage votes = proposalVotes[proposalId];
            bytes memory votingPayload = abi.encode(
                uint16(0), proposalId, votes.forVotes, votes.againstVotes, votes.abstainVotes
            );
            _lzSend({
                _dstChainId: hubChain,
                _payload: votingPayload,
                _refundAddress: payable(address(this)),
                _zroPaymentAddress: address(0x0),
                _adapterParams: bytes(""),
                // NOTE: DAOSatellite needs to be funded beforehand, in the constructor.
                //       There are better solutions, such as cross-chain swaps being built in from the hub chain, but
                //       this is the easiest solution for demonstration purposes.
                _nativeFee: 0.1 ether 
            });            
            proposals[proposalId].voteFinished = true;
            emit SendingQuorumDataToHub(proposalId, votes.forVotes, votes.againstVotes, votes.abstainVotes);
        }
        // TODO: 2. Implement voting cancelation (out of scope for tutorial)
    }

    // Explicitly mark the contract as payable so that additional cross-chain gas & transaction refunds can occur
    receive() external payable { }

    // The following code is copied from the Governor modules to replicate some of its logic

    struct ProposalVote {
        uint256 againstVotes;
        uint256 forVotes;
        uint256 abstainVotes;
        mapping(address => bool) hasVoted;
    }

    enum VoteType {
        Against,
        For,
        Abstain
    }

    /**
     * @dev See {Governor-_countVote}. In this module, the support follows the `VoteType` enum (from Governor Bravo).
     */
    function _countVote(
        uint256 proposalId,
        address account,
        uint8 support,
        uint256 weight
    ) internal virtual {
        ProposalVote storage proposalVote = proposalVotes[proposalId];

        require(!proposalVote.hasVoted[account], "DAOSatellite: vote already cast");
        proposalVote.hasVoted[account] = true;

        if (support == uint8(VoteType.Against)) {
            proposalVote.againstVotes += weight;
        } else if (support == uint8(VoteType.For)) {
            proposalVote.forVotes += weight;
        } else if (support == uint8(VoteType.Abstain)) {
            proposalVote.abstainVotes += weight;
        } else {
            revert("DAOSatellite: invalid value for enum VoteType");
        }
    }

    /**
     * Returns true if the user has voted for the proposal, false if not.
     * @param proposalId the proposal ID of the proposal to check
     * @param account the account to check for voting
     */
    function hasVoted(uint256 proposalId, address account) external view returns(bool) {
        return proposalVotes[proposalId].hasVoted[account];
    }
}

/*
0000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000040
0000000000000000000000000000000000000000000000000000000000000020
1D9793B0FBE0D996C457A870769C06B04C68EFF27177274219AE6773E81A8CE6
*/