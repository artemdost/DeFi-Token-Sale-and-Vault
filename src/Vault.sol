// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IMarket} from "../src/Interfaces/IMarket.sol";
import {ICustomERC721} from "../src/Interfaces/ICustomERC721.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract Vault {
    using SafeERC20 for IERC20;

    address public owner;
    IMarket public market;
    ICustomERC721 public check;

    enum Status {
        DontExist,
        Active,
        Refunded
    }

    struct Deposit {
        Status status;
        address token;
        uint256 amount;
    }

    // address => nft_id => deposit(status, token, amount)
    mapping(address => mapping(uint256 => Deposit)) public deposits;

    modifier isOwner() {
        require(msg.sender == owner, "not an owner");
        _;
    }

    bool private locked;

    modifier noReentrancy() {
        require(!locked, "No reentrancy");
        locked = true;
        _;
        locked = false;
    }

    /**
     * @notice Constructor to initialize the Vault contract.
     * @param _owner The address of the owner of the contract.
     */
    constructor(address _owner) {
        owner = _owner;
    }

    /**
     * @notice Set the Market contract address.
     * @dev This function can only be called by the owner of the contract.
     * @param _market The address of the Market contract.
     */
    function setUpMarket(address _market) public isOwner {
        market = IMarket(_market);
    }

    /**
     * @notice Set the CustomERC721 contract address.
     * @dev This function can only be called by the owner of the contract.
     * @param _check The address of the CustomERC721 contract.
     */
    function setUpCheck(address _check) public isOwner {
        check = ICustomERC721(_check);
    }

    /**
     * @notice Make a deposit and mint an NFT.
     * @dev Deposits can be made in ETH or an allowed ERC20 token.
     * @param _amount The amount of the ERC20 token to be deposited.
     * @param _tokenToPay The address of the ERC20 token to be used for the deposit.
     */
    function makeDeposit(uint256 _amount, address _tokenToPay) public payable {
        if (msg.value > 0) {
            // mint check for msg.sender
            check.safeMint(msg.sender);
            // connect deposit to nft
            deposits[msg.sender][check.getLastId()] =
                Deposit({status: Status.Active, token: address(0), amount: msg.value});
        } else {
            require(market.isAllowed(_tokenToPay), "Token is not allowed");
            IERC20 payToken = IERC20(_tokenToPay);
            // transfer pay tokens from msg.sender to this contract
            payToken.safeTransferFrom(msg.sender, address(this), _amount);
            // mint check for msg.sender
            check.safeMint(msg.sender);
            // connect deposit to nft
            deposits[msg.sender][check.getLastId()] =
                Deposit({status: Status.Active, token: _tokenToPay, amount: _amount});
        }
    }

    /**
     * @notice Return a deposit and burn the corresponding NFT.
     * @dev This function can only be called by the owner of the NFT.
     *      Before the receipt can be burned, it must be approved to manage the Vault contract
     * @param _tokenId The ID of the NFT representing the deposit.
     */
    function returnDeposit(uint256 _tokenId) public payable noReentrancy {
        require(msg.sender == check.ownerOf(_tokenId), "You are not an owner of this NFT");
        require(deposits[msg.sender][_tokenId].status == Status.Active, "Deposit is not active");

        // burn check
        check.burn(_tokenId);

        uint256 depositAmount = deposits[msg.sender][_tokenId].amount;
        uint256 depositBonus = deposits[msg.sender][_tokenId].amount / 50;
        IERC20 payToken = IERC20(deposits[msg.sender][_tokenId].token);

        if (deposits[msg.sender][_tokenId].token != address(0)) {
            // transfer deposit tokens from this contract to msg.sender
            payToken.safeTransfer(msg.sender, depositAmount + depositBonus);
            deposits[msg.sender][_tokenId].status = Status.Refunded;
        } else {
            // transfer deposit eth from this contract to msg.sender
            (bool sent,) = msg.sender.call{value: depositAmount + depositBonus}("");
            require(sent, "Failed to send Ether");
            deposits[msg.sender][_tokenId].status = Status.Refunded;
        }
    }

    receive() external payable {}
}
