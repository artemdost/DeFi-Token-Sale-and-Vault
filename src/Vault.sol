// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import {IMarket} from "../src/IMarket.sol";
import {ICustomERC721} from "../src/ICustomERC721.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Vault{

    using SafeERC20 for IERC20;
    receive() external payable {}

    address owner;
    IMarket market;
    ICustomERC721 check;

    modifier isOwner(){
        require(msg.sender == owner, "not an owner");
        _;
    }

    constructor(address _owner){
        owner = _owner;
    }

    function setUpMarket(address _market) public isOwner{
        market = IMarket(_market);
    }

    function setUpCheck(address _check) public isOwner{
        check = ICustomERC721(_check);
    }   

    function makeDeposit(uint256 amount, address _tokenToPay) public {
        require(market.isAllowed(_tokenToPay) == true, "Token is not allowed");
        IERC20 payToken = IERC20(_tokenToPay);
        // отправляем с адреса покупателя на данный контракт
        payToken.safeTransferFrom(msg.sender, address(this), amount);
        check.safeMint(msg.sender);
    }
}
