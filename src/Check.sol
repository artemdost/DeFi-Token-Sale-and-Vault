// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Check is ERC721, ERC721Burnable, Ownable {
    uint256 private _nextTokenId;

    /**
     * @notice Constructor to initialize the Check contract.
     * @dev Sets the initial owner and initializes the ERC721 token with name and symbol.
     * @param initialOwner The address of the initial owner of the contract.
     */
    constructor(address initialOwner) ERC721("Check", "CHCK") Ownable(initialOwner) {}

    /**
     * @notice Mints a new token to the specified address.
     * @dev Can only be called by the owner. The token ID is automatically incremented.
     * @param to The address to which the new token will be minted.
     */
    function safeMint(address to) public onlyOwner {
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
    }

    /**
     * @notice Retrieves the ID of the last minted token.
     * @dev Can only be called by the owner (in this case by Vault)
     * @return The ID of the last minted token. If no tokens have been minted, revert with ""Check NFT does not exist"
     */
    function getLastId() public view onlyOwner returns (uint256) {
        if (_nextTokenId == 0) {
            revert("Check NFT does not exist");
        } else {
            return _nextTokenId - 1;
        }
    }
}
