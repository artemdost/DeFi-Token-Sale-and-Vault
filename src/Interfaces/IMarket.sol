// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IMarket
 * @dev Interface for the Market contract.
 */
interface IMarket {
    /**
     * @notice Grants permission to pay using the given token.
     * @dev This function can only be called by the owner of the contract.
     * @param _addr The address of the token that will be used.
     */
    function changeMyToken(address _addr) external;

    /**
     * @notice Grants permission to pay using the given token.
     * @dev This function can only be called by the owner of the contract.
     *      It is important to set token addresses before they are used.
     * @param _addr The address of the token to be allowed.
     */
    function allowToken(address _addr) external;

    /**
     * @notice Blocks the permission to pay using the given token.
     * @dev This function can only be called by the owner of the contract.
     * @param _addr The address of the token to be blocked.
     */
    function blockToken(address _addr) external;

    /**
     * @notice Checks if the given token address is allowed for payments.
     * @dev This function is crucial for validating token payments in the buyToken function
     *      and makeDeposit function in the Vault contract.
     * @param _addr The address of the token to check for payment eligibility.
     * @return bool True if the token is allowed, false otherwise.
     */
    function isAllowed(address _addr) external view returns (bool);

    /**
     * @notice Change the address of the vault.
     * @dev This function can only be called by the owner of the contract.
     * @param _vault The address of the vault that will be used.
     */
    function changeVault(address _vault) external;

    /**
     * @notice Allows the user to buy MTK tokens using ETH or another allowed ERC20 token.
     * @dev If the user pays with ETH, the minimum amount required is 2.24 ETH and amount and _tokenToPay values do not matter.
     *      If the user pays with an allowed ERC20 token, the minimum amount required is 1 unit of that token.
     *      A 10% commission is sent to the vault.
     *      If there is an extra ETH after the purchase, it will be refunded to the user.
     * @param amount The amount of the ERC20 token (other than ETH) to be used for purchasing MTK tokens.
     * @param _tokenToPay The address of the ERC20 token to be used for purchasing MTK tokens.
     */
    function buyToken(uint256 amount, address _tokenToPay) external payable;
}
