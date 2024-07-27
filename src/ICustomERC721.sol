// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface ICustomERC721 is IERC721 {
    function safeMint(address to) external;
}
