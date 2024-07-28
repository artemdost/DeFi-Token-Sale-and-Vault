// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface ICustomERC721 is IERC721 {
    /**
     * @notice Mints a new token to the specified address.
     * @dev Can only be called by authorized accounts as per the implementing contract's rules.
     * @param to The address to which the new token will be minted.
     */
    function safeMint(address to) external;

    /**
     * @notice Retrieves the ID of the last minted token.
     * @return The ID of the last minted token.
     */
    function getLastId() external returns (uint);

    /**
     * @notice Burns the specified token.
     * @param tokenId The ID of the token to be burned.
     */
    function burn(uint256 tokenId) external;
}
