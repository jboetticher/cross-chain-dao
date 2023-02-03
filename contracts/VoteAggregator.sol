// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./LayerZero/lzApp/NonblockingLzApp.sol";
import "@openzeppelin/contracts/utils/Timers.sol";
import "@openzeppelin/contracts/utils/Checkpoints.sol";
import "@openzeppelin/contracts/governance/utils/IVotes.sol";

// setTrustedRemote: the only contract that should be trusted is the DAO on the hub chain


// This contract doesn't adhere to a lot of the interfaces provided by IGovernor and its modules
contract VoteAggregator is NonblockingLzApp {
    using Checkpoints for Checkpoints.History;

    event RemoteProposalReceived(uint256 id, uint256 localVoteStart);

    error VotingHasClosedOnThisChain();

    constructor(
        uint16 _hubChain,
        address _endpoint,
        IVotes _token,
        uint _targetSecondsPerBlock
    ) NonblockingLzApp(_endpoint) {
        hubChain = _hubChain;
        token = _token;
        targetSecondsPerBlock = _targetSecondsPerBlock;
    }

    uint16 public immutable hubChain;
    IVotes public immutable token;
    uint256 public immutable targetSecondsPerBlock;
    uint256 private _quorumNumerator; // DEPRECATED
    mapping(uint256 => RemoteProposal) public proposals;

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
            "VoteAggregator: vote not currently active"
        );
        require(
            isProposal(proposalId), 
            "VoteAggregator: not a started vote"
        );

        uint256 weight = _getVotes(
            msg.sender,
            proposal.localVoteStart
        );
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

        (uint256 option, bytes memory payload) = abi.decode(
            _payload,
            (uint256, bytes)
        );

        // Do 1 of 2 things:
        // 0. Begin a proposal on the local chain, with local block times
        if (option == 0) {
            (uint256 proposalId, uint256 proposalStart) = abi.decode(payload, (uint256, uint256));
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
            uint256 proposalId = abi.decode(payload, (uint256));
            bytes memory votesAndQuorum = abi.encode(proposalId, 0, 0); /* TODO: insert votes and quorum data */
            bytes memory votingPayload = abi.encode(0, votesAndQuorum);
            _lzSend({
                _dstChainId: hubChain,
                _payload: votingPayload,
                _refundAddress: payable(address(this)),
                _zroPaymentAddress: address(0x0),
                _adapterParams: bytes(""),
                _nativeFee: 0.1 ether
            });
        }
        // TODO: 2. Implement voting cancelation (out of scope for tutorial)
    }

    // The following code is copied from the Governor modules to replicate some of its logic

    Checkpoints.History private _quorumNumeratorHistory;
    event QuorumNumeratorUpdated(
        uint256 oldQuorumNumerator,
        uint256 newQuorumNumerator
    );

    /**
     * Read the voting weight from the token's built in snapshot mechanism (see {Governor-_getVotes}).
     */
    function _getVotes(
        address account,
        uint256 blockNumber
    ) internal view virtual returns (uint256) {
        return token.getPastVotes(account, blockNumber);
    }

    /**
     * @dev Returns the current quorum numerator. See {quorumDenominator}.
     */
    function quorumNumerator() public view virtual returns (uint256) {
        return
            _quorumNumeratorHistory._checkpoints.length == 0
                ? _quorumNumerator
                : _quorumNumeratorHistory.latest();
    }

    /**
     * @dev Returns the quorum numerator at a specific block number. See {quorumDenominator}.
     */
    function quorumNumerator(uint256 blockNumber)
        public
        view
        virtual
        returns (uint256)
    {
        // If history is empty, fallback to old storage
        uint256 length = _quorumNumeratorHistory._checkpoints.length;
        if (length == 0) {
            return _quorumNumerator;
        }

        // Optimistic search, check the latest checkpoint
        Checkpoints.Checkpoint memory latest = _quorumNumeratorHistory
            ._checkpoints[length - 1];
        if (latest._blockNumber <= blockNumber) {
            return latest._value;
        }

        // Otherwise, do the binary search
        return _quorumNumeratorHistory.getAtBlock(blockNumber);
    }

    /**
     * @dev Returns the quorum denominator. Defaults to 100, but may be overridden.
     */
    function quorumDenominator() public view virtual returns (uint256) {
        return 100;
    }

    /**
     * @dev Returns the quorum for a block number, in terms of number of votes: `supply * numerator / denominator`.
     */
    function quorum(uint256 blockNumber) public view virtual returns (uint256) {
        return
            (token.getPastTotalSupply(blockNumber) *
                quorumNumerator(blockNumber)) / quorumDenominator();
    }

    /**
     * @dev Changes the quorum numerator.
     *
     * Emits a {QuorumNumeratorUpdated} event.
     *
     * Requirements:
     *
     * - New numerator must be smaller or equal to the denominator.
     */
    function _updateQuorumNumerator(uint256 newQuorumNumerator)
        internal
        virtual
    {
        require(
            newQuorumNumerator <= quorumDenominator(),
            "GovernorVotesQuorumFraction: quorumNumerator over quorumDenominator"
        );

        uint256 oldQuorumNumerator = quorumNumerator();

        // Make sure we keep track of the original numerator in contracts upgraded from a version without checkpoints.
        if (
            oldQuorumNumerator != 0 &&
            _quorumNumeratorHistory._checkpoints.length == 0
        ) {
            _quorumNumeratorHistory._checkpoints.push(
                Checkpoints.Checkpoint({
                    _blockNumber: 0,
                    _value: SafeCast.toUint224(oldQuorumNumerator)
                })
            );
        }

        // Set new quorum for future proposals
        _quorumNumeratorHistory.push(newQuorumNumerator);

        emit QuorumNumeratorUpdated(oldQuorumNumerator, newQuorumNumerator);
    }

    mapping(uint256 => ProposalVote) _proposalVotes;

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
        ProposalVote storage proposalVote = _proposalVotes[proposalId];

        require(!proposalVote.hasVoted[account], "GovernorVotingSimple: vote already cast");
        proposalVote.hasVoted[account] = true;

        if (support == uint8(VoteType.Against)) {
            proposalVote.againstVotes += weight;
        } else if (support == uint8(VoteType.For)) {
            proposalVote.forVotes += weight;
        } else if (support == uint8(VoteType.Abstain)) {
            proposalVote.abstainVotes += weight;
        } else {
            revert("GovernorVotingSimple: invalid value for enum VoteType");
        }
    }
}


/*
0000000000000000000000000000000000000000000000000000000000000020
00000000000000000000000000000000000000000000000000000000000000a0
0000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000040
0000000000000000000000000000000000000000000000000000000000000040
4a23f3e29309a9c63865d5852a14171a9b40a37537aa3d76f72a51ca74ad150a
0000000000000000000000000000000000000000000000000000000063daeb6c

0000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000040
0000000000000000000000000000000000000000000000000000000000000040
4a23f3e29309a9c63865d5852a14171a9b40a37537aa3d76f72a51ca74ad150a
0000000000000000000000000000000000000000000000000000000063daf0e0

0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000404a23f3e29309a9c63865d5852a14171a9b40a37537aa3d76f72a51ca74ad150a0000000000000000000000000000000000000000000000000000000063daeb6c



uint256: 0
1:
uint256: 33534673675224055151516715811226726201658247519517012145911401487859970807050
2:
uint256: 1675292896
3:
bytes: 
*/