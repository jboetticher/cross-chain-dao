// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "./OFTVotes.sol";

contract CrossChainDAOToken is ERC20Votes, OFTVotes {
    constructor(uint256 _initialSupply, address _lzEndpoint)
        OFTVotes("Cross Chain DAO Token", "CCDT", _lzEndpoint)
        ERC20Permit("Cross Chain DAO Token")
    {
        _mint(msg.sender, _initialSupply);
    }

    // The functions below are overrides required by Solidity.

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override(ERC20Votes) {
        super._afterTokenTransfer(from, to, amount);
    }

    function _mint(address to, uint256 amount) internal override(ERC20Votes) {
        super._mint(to, amount);
    }

    function _burn(address account, uint256 amount)
        internal
        override(ERC20Votes)
    {
        super._burn(account, amount);
    }
}
