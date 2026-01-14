// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract StashToken is ERC20, ERC20Permit {
    constructor() ERC20Permit("StashToken") ERC20("StashToken", "STH") {
        uint256 _initialSupply = 1000000 * (10 ** decimals());
        _mint(msg.sender, _initialSupply);
    }
}
