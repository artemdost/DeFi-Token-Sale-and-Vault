// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IMarket {
    // Функция для установки родного токена
    function setUpMyToken(address _addr) external;

    // Функция для разрешения токена
    function allowToken(address _addr) external;

    // Функция для блокировки токена
    function blockToken(address _addr) external;

    // Функция для установки хранилища
    function setUpValut(address _vault) external;

    // Функция для проверки, разрешен ли токен
    function isAllowed(address _addr) external view returns (bool);

    // Функция для покупки токена за ERC20 токен
    function buyToken(uint256 amount, address _tokenToPay) external;

    // Функция для покупки токена за эфир
    function buyToken() external payable;
}
