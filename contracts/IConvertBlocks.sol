// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract BlockConverter {
    // The best implementation would likely have an oracle that provides this data.
    // Alternatively, you could just have the user import this information in the propose() constructor as well.
    // The issue with that is user error and breaking the abstract contract. 
    function convertBlocks(uint16 chainId, uint256 blockNum) public view returns(uint256) {
        return blockNum;
    }
}

