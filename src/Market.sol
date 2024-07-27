// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract Market {
    using SafeERC20 for IERC20;

    address public owner;

    // Наш токен
    IERC20 MTK;
    // Наше хранилище
    address public vault;
    // Допустимые адреса токенов для покупки
    mapping(address => bool) public allowedTokens;

    constructor(address _owner, address _vault) {
        owner = _owner;
        vault = _vault;
    }

    modifier isOwner() {
        require(msg.sender == owner, "not an owner");
        _;
    }

    bool locked;

    modifier noReentrancy() {
        require(!locked, "No reentrancy");
        locked = true;
        _;
        locked = false;
    }

    // установить родной токен
    function setUpMyToken(address _addr) public isOwner {
        MTK = IERC20(_addr);
    }

    function allowToken(address _addr) public isOwner {
        allowedTokens[_addr] = true;
    }

    function blockToken(address _addr) public isOwner {
        allowedTokens[_addr] = false;
    }

    // установить хранилище
    function setUpValut(address _vault) public isOwner {
        vault = _vault;
    }

    // возвращает, разрешен ли токен к получению
    function isAllowed(address _addr) public view returns(bool){
        return allowedTokens[_addr];
    }

    // купить токен за токен erc20
    function buyToken(uint256 amount, address _tokenToPay) public {
        require(allowedTokens[_tokenToPay] == true, "Token is not allowed");
        IERC20 payToken = IERC20(_tokenToPay);
        // отправляем с адреса покупателя на данный контракт
        payToken.safeTransferFrom(msg.sender, address(this), amount + amount / 10);
        // отправляем наш токен покупателю
        MTK.safeTransfer(msg.sender, amount);
        // переводим 10 процентов в хранилище
        payToken.safeTransfer(vault, amount / 10);
    }

    uint256 public refund;
    // для покупки за эфир

    function buyToken() public payable noReentrancy {
        require(msg.value >= 2.24 ether, "Is not enough to buy at least 1 token");
        uint256 amountMTK = msg.value / (2 ether);
        MTK.safeTransfer(msg.sender, amountMTK);
        (bool sent,) = address(vault).call{value: msg.value / 10}("");
        require(sent, "Failed to send Ether");
        refund = msg.value - (amountMTK * 2 ether) - msg.value / 10;
        if (refund >= 1000000000000) {
            (sent,) = msg.sender.call{value: refund}("");
            require(sent, "Failed to send Ether");
        }
    }
}
