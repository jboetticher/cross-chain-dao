// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract BlockConverter {
    // The best implementation would likely have an oracle that provides this data, and will continuously update
    // either on each spoke net directly or via GMP. This is still an issue.
    // You could just have the user import this information in the propose() constructor as well.
    // The issue with that is user error and breaking the abstract contract. 
    // For this tutorial, Moonbase Alpha will be the hub and Fantom Testnet and Avalanche Fuji, with some crude
    // estimations of the block time.
    function convertBlocks(uint16 chainId, uint256 blockNum) public view returns(uint256) {
        // Moonbase Alpha block time: 12 seconds
        uint basis = 3410805;
        
        // Fantom Testnet block time: 2 seconds
        if(chainId == 10112) {
            uint fantomBasis = 13008656;
            return fantomBasis + block.number - basis * 12 / 2;
        }
        // Avalanche Fuji block time: 3 seconds
        else if(chainId == 10106) {
            uint fujiBasis = 17253524;
            return fujiBasis + block.number - basis * 12 / 3;
        }

        return blockNum;
    }
}

