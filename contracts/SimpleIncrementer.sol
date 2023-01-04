// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

contract SimpleIncrementer {
    uint256 public incrementer;

    function increment() external {
        incrementer += 1;
    }
}