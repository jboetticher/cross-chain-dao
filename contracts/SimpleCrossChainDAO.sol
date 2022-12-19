// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.0;

// contract SimpleCrossChainDAO  {

//     uint64 proposalThreshold = 10;

//     struct ProposalCore {
//         uint64 voteStarts;
//         uint64 voteEnd;
//         bool executed;
//         bool canceled;
//     }

//     function vote(uint proposalId) public {

//     }

//     function propose(
//         address[] memory targets,
//         uint256[] memory values,
//         bytes[] memory calldatas,
//         string memory description
//     ) public virtual override returns (uint256) {
//         require(
//             getVotes(msg.sender, block.number - 1) >= proposalThreshold,
//             "Governor: proposer votes below proposal threshold"
//         );

//         uint256 proposalId = hashProposal(
//             targets,
//             values,
//             calldatas,
//             keccak256(bytes(description))
//         );

//         require(
//             targets.length == values.length,
//             "Governor: invalid proposal length"
//         );
//         require(
//             targets.length == calldatas.length,
//             "Governor: invalid proposal length"
//         );
//         require(targets.length > 0, "Governor: empty proposal");

//         ProposalCore storage proposal = _proposals[proposalId];
//         require(
//             proposal.voteStart.isUnset(),
//             "Governor: proposal already exists"
//         );

//         uint64 snapshot = block.number.toUint64() + votingDelay().toUint64();
//         uint64 deadline = snapshot + votingPeriod().toUint64();

//         proposal.voteStart.setDeadline(snapshot);
//         proposal.voteEnd.setDeadline(deadline);

//         emit ProposalCreated(
//             proposalId,
//             _msgSender(),
//             targets,
//             values,
//             new string[](targets.length),
//             calldatas,
//             snapshot,
//             deadline,
//             description
//         );

//         return proposalId;
//     }

//     function hashProposal(
//         address[] memory targets,
//         uint256[] memory values,
//         bytes[] memory calldatas,
//         bytes32 descriptionHash
//     ) public pure virtual override returns (uint256) {
//         return
//             uint256(
//                 keccak256(
//                     abi.encode(targets, values, calldatas, descriptionHash)
//                 )
//             );
//     }
// }
