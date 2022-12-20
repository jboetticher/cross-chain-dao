// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./LayerZero/lzApp/NonblockingLzApp.sol";
import "@openzeppelin/contracts/utils/Timers.sol";


contract VoteAggregator is NonblockingLzApp {
    using Timers for Timers.BlockNumber;

    error VotingHasClosedOnThisChain();

    constructor(uint16 _hubChain, address _endpoint)
        NonblockingLzApp(_endpoint)
    {
        hubChain = _hubChain;
    }

    uint16 public immutable hubChain;

    struct RemoteProposal {
        // Blocks provided by the hub chain as to when the local votes should start/finish. 
        // This guides the algorithm for determining what the right vote weights from the CrossChainToken should be.
        // NOTE:    This is an alright solution given the assumption that there is no downtime on any chain. 
        //          Will need a proper solution still to fix in case of such a scenario
        Timers.BlockNumber localVoteStart;
        Timers.BlockNumber localVoteEnd;

        bool voteFinished;
        bool executed;
        bool canceled;
    }


    // setTrustedRemote: the only contract that should be trusted is the DAO on the hub chain

    function castVote(uint256 proposalId, uint8 support)
        public
        virtual
        returns (uint256 balance)
    {
        // Get the vote weights from the local CrossChainToken implementation
        // Check them against the local block boundaries. If the boundaries are closed, then revert

        // Doesn't need to send a vote
    }

    function _nonblockingLzReceive(
        uint16 _srcChainId,
        bytes memory _srcAddress,
        uint64 _nonce,
        bytes memory _payload
    ) internal override {
        // Do 1 of 2 things:
        // 1. Begin a proposal on the local chain, with local block times
        // 2. Send vote results back to the local chain
    }
}
