// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract Market {
    using SafeERC20 for IERC20;

    // Own token
    IERC20 public MTK;
    // Address of vault
    address public vault;
    // Address of the contract owner
    address public owner;
    // Tokens which could be used for purchasing MTK tokens
    mapping(address => bool) public allowedTokens;

    bool private locked;

    uint256 public refund;

    modifier isOwner() {
        require(msg.sender == owner, "not an owner");
        _;
    }

    modifier noReentrancy() {
        require(!locked, "No reentrancy");
        locked = true;
        _;
        locked = false;
    }

    /**
     * @notice Constructor to initialize the Market contract.
     * @dev Sets the owner, vault, and MTK token addresses.
     * @param _owner The address of the owner of the contract.
     * @param _vault The address of the vault.
     * @param _myToken The address of the MTK token.
     */
    constructor(address _owner, address _vault, address _myToken) {
        owner = _owner;
        vault = _vault;
        MTK = IERC20(_myToken);
    }

    /**
     * @notice Grants permission to pay using the given token.
     * @dev This function can only be called by the owner of the contract.
     * @param _addr The address of the token that will be used.
     */
    function changeMyToken(address _addr) public isOwner {
        MTK = IERC20(_addr);
    }

    /**
     * @notice Grants permission to pay using the given token.
     * @dev This function can only be called by the owner of the contract.
     *      It is important to set token addresses before they are used.
     * @param _addr The address of the token to be allowed.
     */
    function allowToken(address _addr) public isOwner {
        allowedTokens[_addr] = true;
    }

    /**
     * @notice Blocks the permission to pay using the given token.
     * @dev This function can only be called by the owner of the contract.
     * @param _addr The address of the token to be blocked.
     */
    function blockToken(address _addr) public isOwner {
        allowedTokens[_addr] = false;
    }

    /**
     * @notice Checks if the given token address is allowed for payments.
     * @dev This function is crucial for validating token payments in the buyToken function
     *      and makeDeposit function in the Vault contract.
     * @param _addr The address of the token to check for payment eligibility.
     * @return bool True if the token is allowed, false otherwise.
     */
    function isAllowed(address _addr) public view returns (bool) {
        return allowedTokens[_addr];
    }

    /**
     * @notice Change the address of the vault.
     * @dev This function can only be called by the owner of the contract.
     * @param _vault The address of the vault that will be used.
     */
    function changeVault(address _vault) public isOwner {
        vault = _vault;
    }

    /**
     * @notice Allows the user to buy MTK tokens using ETH or another allowed ERC20 token.
     * @dev If the user pays with ETH, the minimum amount required is 2.24 ETH and amount and _tokenToPay values do not matter
     *      A 10% commission is sent to the vault.
     *      If there is an extra ETH after the purchase, it will be refunded to the user.
     *      Before pay token can be transfered from user, it must be approved to manage the Market contract
     * @param amount The amount of the ERC20 token (other than ETH) to be used for purchasing MTK tokens.
     * @param _tokenToPay The address of the ERC20 token to be used for purchasing MTK tokens.
     */
    function buyToken(uint256 amount, address _tokenToPay) public payable noReentrancy {
        if (msg.value > 0) {
            require(msg.value >= 2.24 ether, "Is not enough to buy at least 1 token");
            // Amount of MTK tokens to be received by user
            uint256 amountMTK = msg.value / (2 ether);
            // Transfer purchased tokens from this contract to msg.sender
            MTK.safeTransfer(msg.sender, amountMTK);
            // Transfer 10 percent commission to vault
            (bool sent,) = address(vault).call{value: msg.value / 10}("");
            require(sent, "Failed to send Ether");
            // Check if there are extra eth and transfer eth to msg.sender back if it is
            refund = msg.value - (amountMTK * 2 ether) - (msg.value / 10);
            if (refund >= 1000000000000) {
                (sent,) = msg.sender.call{value: refund}("");
                require(sent, "Failed to send Ether");
            }
        } else {
            require(allowedTokens[_tokenToPay] == true, "Token is not allowed");
            IERC20 payToken = IERC20(_tokenToPay);
            // Transfer pay tokens + 10 percent from msg.sender to this contract
            payToken.safeTransferFrom(msg.sender, address(this), amount);
            // Transfer 10 percent from msg.sender to vault
            payToken.safeTransferFrom(msg.sender, vault, amount / 10);
            // Transfer purchased tokens MTK to msg.sender
            MTK.safeTransfer(msg.sender, amount);
        }
    }
}
