# DeFi-Token-Sale-and-Vault

## Описание
DeFi-Token-Sale-and-Vault Protocol позволяет пользователям покупать токены MyToken (ERC20) за USDT, USDC, DAI или Ether. Протокол взимает комиссию в размере 10% от общей суммы покупки, которая перечисляется в контракт Vault. Пользователи также могут вносить депозиты в Vault и получать NFT в качестве чека за депозит. Позже пользователи могут вернуть NFT и получить назад депозит плюс 2% бонуса, которые берутся из комиссионых средств, которые были сформированы благодаря покупкам MyToken.

## Функциональность

### Покупка MyToken  
Пользователи могут покупать MyToken за USDT, USDC, DAI или Ether:  
    1. Покупка за стейблкоины: Пользователь платит сумму + 10% комиссии, стоимость 1 MyToken = 1 StableCoin.
    2. Покупка за Ether: Минимальная сумма покупки - 2 Ether, стоимость 1 MyToken = 2 Ether.  
  
### Депозиты в Vault
Пользователи могут вносить депозиты в Vault, получая в ответ NFT как чек за депозит. Позже они могут вернуть NFT и получить назад депозит плюс 2% бонуса.  
  
### Инструкция к развертыванию:  
1. Разверните контракт Vault, передайте свой адрес, чтобы стать владельцем.  
2. Разверните контракт Check, передайте адрес Vault, чтобы сделать его владельцем.  
3. Установите через setUpCheck в контракте Vault адрес Check.  
4. Разверните свой токен MyToken, если у вас его нет.  
5. Разверните контракт Market, передайте свой адрес, адрес Vault, адрес MyToken.  
6. Установите через setUpMarket в контракте Vault адрес Market.
7. Отправьте некоторое количество ваших токенов на адрес Market, чтобы пользователи смогли его приобрести.
8. В контракте Market через функцию allowToken предоставьте адреса токенов, которые контракт смог бы принимать в качестве оплаты.
