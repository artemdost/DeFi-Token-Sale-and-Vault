# DeFi-Token-Sale-and-Vault  
ENG  
## Description
DeFi-Token-Sale-and-Vault Protocol allows users to purchase MyToken (ERC20) using USDT, USDC, DAI, or Ether. The protocol charges a 10% fee on the total purchase amount, which is transferred to the Vault contract. Users can also deposit funds into the Vault and receive an NFT as a receipt for the deposit. Later, users can return the NFT to get their deposit back plus a 2% bonus, which comes from the commission funds accumulated through MyToken purchases.

## Functionality

### Purchase MyToken  
Users can buy MyToken using USDT, USDC, DAI, or Ether:  
    1. Purchase with stablecoins: User pays the amount + 10% commission, 1 MyToken = 1 StableCoin.  
    2. Purchase with Ether: Minimum purchase amount - 2 Ether, 1 MyToken = 2 Ether.  
  
### Deposits in Vault
Users can deposit funds into the Vault and receive an NFT as a receipt for the deposit. Later, they can return the NFT to get their deposit back plus a 2% bonus.

## Contracts:  
Important (Required for deployment)  
1. Market.sol - Contract for purchasing tokens.
2. Vault.sol - Contract for storing commissions and deposits. Accepts deposits and issues receipts. Returns deposits and burns receipts.  
3. Check.sol - ERC721 token receipt.
3. MyToken.sol - ERC20 your token.
4. IMarket.sol - Interface for Market.
5. ICustomERC721.sol - Added functions for burning and getting the ID of the last created NFT.  
  
For testing  
1. USDC.sol - ERC20 simulation of USDC.

## Deployment instructions:  
1. Deploy the Vault contract, passing your address to become the owner.  
2. Deploy the Check contract, passing the Vault address to make it the owner.  
3. Set the Check address in the Vault contract using the setUpCheck function.  
4. Deploy your MyToken if you don't have it already.  
5. Deploy the Market contract, passing your address, the Vault address, and the MyToken address.  
6. Set the Market address in the Vault contract using the setUpMarket function.
7. Send some of your tokens to the Market address so that users can purchase them.
8. In the Market contract, allow stablecoin addresses for payment using the allowToken function.
  
RU  
## Описание
DeFi-Token-Sale-and-Vault Protocol позволяет пользователям покупать токены MyToken (ERC20) за USDT, USDC, DAI или Ether. Протокол взимает комиссию в размере 10% от общей суммы покупки, которая перечисляется в контракт Vault. Пользователи также могут вносить депозиты в Vault и получать NFT в качестве чека за депозит. Позже пользователи могут вернуть NFT и получить назад депозит плюс 2% бонуса, которые берутся из комиссионых средств, которые были сформированы благодаря покупкам MyToken.

## Функциональность

### Покупка MyToken  
Пользователи могут покупать MyToken за USDT, USDC, DAI или Ether:  
    1. Покупка за стейблкоины: Пользователь платит сумму + 10% комиссии, стоимость 1 MyToken = 1 StableCoin.  
    2. Покупка за Ether: Минимальная сумма покупки - 2 Ether, стоимость 1 MyToken = 2 Ether.  
  
### Депозиты в Vault
Пользователи могут вносить депозиты в Vault, получая в ответ NFT как чек за депозит. Позже они могут вернуть NFT и получить назад депозит плюс 2% бонуса.

## Контракты:  
Важные (Нужны для деплоя)  
1. Market.sol - контракт, через который осуществляется покупка токенов.
2. Vault.sol - контракт, хранилище комиссионых и депозитов. Принимает депозиты, выдавая чек. Возвращает депозиты, сжигая чек.  
3. Check.sol - ERC721 токен чека
3. MyToken.sol - ERC20 ваш токен
4. IMarket.sol - интерфейс для Market
5. ICustomERC721.sol - добавлены функция сжигания и получения Id последнего созданного NFT.  
  
Для тестов  
1. USDC.sol - ERC20 симуляция USDC

## Инструкция к развертыванию:  
1. Разверните контракт Vault, передайте свой адрес, чтобы стать владельцем.  
2. Разверните контракт Check, передайте адрес Vault, чтобы сделать его владельцем.  
3. Установите через setUpCheck в контракте Vault адрес Check.  
4. Разверните свой токен MyToken, если у вас его нет.  
5. Разверните контракт Market, передайте свой адрес, адрес Vault, адрес MyToken.  
6. Установите через setUpMarket в контракте Vault адрес Market.
7. Отправьте некоторое количество ваших токенов на адрес Market, чтобы пользователи смогли его приобрести.
8. В контракте Market через функцию allowToken предоставьте адреса стейблкоинов, которые контракт смог бы принимать в качестве оплаты.



