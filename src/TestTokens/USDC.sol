// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

/////////////////////////////////////////////THIS TOKEN IS ONLY FOR TEST /////////////////////////////////////////////////////

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract USDCtoken is ERC20, Ownable {
    constructor(address initialOwner) ERC20("USDCtoken", "USDC") Ownable(initialOwner) {}

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}
