// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./LayerZero/lzApp/NonblockingLzApp.sol";

contract VoteAggregator is NonblockingLzApp {
    error VotingHasClosedOnThisChain();

    constructor(uint16 _hubChain, address _endpoint)
        NonblockingLzApp(_endpoint)
    {
        hubChain = _hubChain;
    }

    uint16 public immutable hubChain;

    // setTrustedRemote: the only contract that should be trusted is the DAO on the hub chain

    function castVote(uint256 proposalId, uint8 support)
        public
        virtual
        returns (uint256 balance)
    {
        // Get the vote weights from the local CrossChainToken implementation
        // Check them against the local block boundaries. If the boundaries are closed, then revert

        // Send a message to the cross-chain DAO, which should hold all of the votes in map for each chain
    }

    function _nonblockingLzReceive(
        uint16 _srcChainId,
        bytes memory _srcAddress,
        uint64 _nonce,
        bytes memory _payload
    ) internal override {
        // Decode information from the hub chain, should be the block boundries
    }
}
