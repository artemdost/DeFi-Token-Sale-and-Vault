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

    enum Status{NotExist, Active, Refunded}

    struct Deposit{
        Status status; // NotExist - не существует, Active - существует, Refunded - забрали
        address token; // адрес токена, если это erc20, иначе address(0)
        uint amount; // либо msg.value либо amount токенов
    }

    mapping (address => mapping(uint => Deposit)) deposits;

    modifier isOwner(){
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

    constructor(address _owner){
        owner = _owner;
    }

    function setUpMarket(address _market) public isOwner{
        market = IMarket(_market);
    }

    function setUpCheck(address _check) public isOwner{
        check = ICustomERC721(_check);
    }   

    function makeDeposit(uint256 _amount, address _tokenToPay) public payable{
        if (msg.value > 0){
            // минтим нфт тому, кто сделал депозит
            check.safeMint(msg.sender);
            // создаем депозит
            deposits[msg.sender][check.getLastId()] = Deposit({
                status: Status(1), // или false, в зависимости от условий вашего контракта
                token: address(0), // указать адрес токена, если это не ETH
                amount: msg.value // или другое значение, если это не ETH
            });
        } else {
            require(market.isAllowed(_tokenToPay) == true, "Token is not allowed");
            IERC20 payToken = IERC20(_tokenToPay);
            // отправляем с адреса покупателя на данный контракт
            payToken.safeTransferFrom(msg.sender, address(this), _amount);
            // минтим нфт тому, кто сделал депозит
            check.safeMint(msg.sender);

            // создаем депозит
            deposits[msg.sender][check.getLastId()] = Deposit({
                status: Status(1), // или false, в зависимости от условий вашего контракта
                token: _tokenToPay, // указать адрес токена, если это не ETH
                amount: _amount // или другое значение, если это не ETH
            });
        }
    }


    // вернуть депозит
    function returnDeposit(uint _tokenId) public noReentrancy payable{
        require(msg.sender == check.ownerOf(_tokenId), "You are not an owner of this NFT");

        require(deposits[msg.sender][_tokenId].status != Status(2)
        && deposits[msg.sender][_tokenId].status != Status(0));
        
        check.burn(_tokenId);
        // отправляем токены с данного нфт обратно юзеру, после сжигания нфт
        deposits[msg.sender][_tokenId].status = Status(2);
        if (deposits[msg.sender][_tokenId].token != address(0)){
            IERC20(deposits[msg.sender][_tokenId].token).safeTransfer(
                msg.sender,
                deposits[msg.sender][_tokenId].amount + deposits[msg.sender][_tokenId].amount / 100 * 2
            );
        } else {
            (bool sent,) = msg.sender.call{value: deposits[msg.sender][_tokenId].amount
            + deposits[msg.sender][_tokenId].amount / 100 * 2
            }("");
            require(sent);
        }
    }

}
