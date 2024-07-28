// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyToken is ERC20, Ownable {
    /**
     * @notice Constructor to initialize the MyToken contract.
     * @dev Sets the initial owner of the contract and initializes the ERC20 token with name "MyToken" and symbol "MTK".
     * @param initialOwner The address of the initial owner of the contract.
     */
    constructor(address initialOwner) ERC20("MyToken", "MTK") Ownable(initialOwner) {}

    /**
     * @notice Mints new tokens to the specified address.
     * @dev Can only be called by the owner of the contract.
     * @param to The address to which the minted tokens will be sent.
     * @param amount The amount of tokens to be minted.
     */
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}
