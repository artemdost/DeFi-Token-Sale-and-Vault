// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IMarket} from "../src/Interfaces/IMarket.sol";
import {ICustomERC721} from "../src/Interfaces/ICustomERC721.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract Vault {
    using SafeERC20 for IERC20;

    event MarketAddressChanged(address _market);
    event CheckAddressChanged(address _check);
    event NewDeposit(address _who, uint256 _amount, address _token);
    event DepositReturned(address _who, uint256 _amount, address _token);

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

        emit MarketAddressChanged(_market);
    }

    /**
     * @notice Set the CustomERC721 contract address.
     * @dev This function can only be called by the owner of the contract.
     * @param _check The address of the CustomERC721 contract.
     */
    function setUpCheck(address _check) public isOwner {
        check = ICustomERC721(_check);

        emit CheckAddressChanged(_check);
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

            emit NewDeposit(msg.sender, msg.value, address(0));
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

            emit NewDeposit(msg.sender, _amount, _tokenToPay);
        }
    }

    /**
     * @notice Return a deposit and burn the corresponding NFT.
     * @dev This function can only be called by the owner of the NFT.
     *      Before the receipt can be burned, it must be approved to manage the Vault contract
     * @param _tokenId The ID of the NFT representing the deposit.
     */
    function returnDeposit(uint256 _tokenId) public payable noReentrancy {
        Deposit memory deposit = deposits[msg.sender][_tokenId];

        require(msg.sender == check.ownerOf(_tokenId), "You are not an owner of this NFT");
        require(deposit.status == Status.Active, "Deposit is not active");

        // burn check
        check.burn(_tokenId);

        uint256 depositAmount = deposit.amount;
        uint256 depositBonus = deposit.amount * 200 / 10000;
        IERC20 payToken = IERC20(deposit.token);

        if (deposit.token != address(0)) {
            // transfer deposit tokens from this contract to msg.sender
            payToken.safeTransfer(msg.sender, depositAmount + depositBonus);
            deposit.status = Status.Refunded;

            emit DepositReturned(msg.sender, depositAmount + depositBonus, address(0));
        } else {
            // transfer deposit eth from this contract to msg.sender
            (bool sent,) = msg.sender.call{value: depositAmount + depositBonus}("");
            require(sent, "Failed to send Ether");
            deposit.status = Status.Refunded;

            emit DepositReturned(msg.sender, msg.value, address(0));
        }
    }

    receive() external payable {}
}
