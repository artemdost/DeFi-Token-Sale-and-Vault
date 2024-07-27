// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract Market{
    using SafeERC20 for IERC20;
    address public owner;

    // Наш токен
    IERC20 MTK;
    // Наше хранилище
    address public vault;
    constructor(){
        owner = msg.sender;

    }

    modifier isOwner(){
        require(msg.sender == owner, "not an owner");
        _;
    }
    // ты идиот ты же токен mtk не установил ьоже нах

    // установить родной токен
    function setUpMyToken(address _addr) public isOwner{
        MTK = IERC20(_addr);
    }

    // установить хранилище
    function setUpValut(address _vault) public isOwner{
        vault = _vault;
    }

    // купить токен
    function buyToken(uint256 amount, address _tokenToPay) public {
        IERC20 payToken = IERC20(_tokenToPay);
        payToken.safeTransferFrom(msg.sender, address(this), amount);
        MTK.safeTransfer(msg.sender, amount);
    }            
}