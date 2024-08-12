# Governance Token and NFT Management System
## Description
This project implements a governance system based on tokens, allowing users to participate in the decision-making process of a decentralized organization. The system includes an ERC20 governance token, a voting mechanism with defined voting periods, and an ERC721-based NFT management system that is controlled through governance token holders' voting.

## Key Features
Governance Token:
1. Users can purchase governance tokens using only USDT.
2. Token price: 1 token = 1 USDT.
3. The more tokens a user holds, the higher their voting power. The maximum voting weight is 5000 tokens.
 
Voting and Proposals:
1. Proposals can be created by all users, except for proposals related to unfreezing.
2. Each proposal has a voting period of 2 weeks.
3. After the voting period ends, the proposal execution period is 1 week.
## Contracts
Important (Required for Deployment):

1. DAO.sol - The contract that includes the main DAO functionality. (inherits from Market.sol)
2. Market.sol - The contract through which tokens are purchased.
3. NFT.sol - An ERC721 token managed by the DAO.
4. GOVR.sol - ERC20 governance token.

For Testing:  
1. USDT.sol - ERC20 simulation of USDT.
## Deployment Instructions
1. Deploy the DAO contract, passing an address to set it as the owner.
2. Deploy the GOVR contract, passing an address to set it as the owner.
3. Deploy the NFT contract, passing the DAO address to set it as the owner.
4. Transfer some of your tokens to the DAO address so that users can purchase GOVR tokens.


# Система управления токенами Governance и NFT
## Описание
Этот проект реализует систему управления на основе токенов, которая позволяет пользователям участвовать в процессе принятия решений децентрализованной организации. В систему входят ERC20 токен управления, механизм голосования определенным периодом голосования, а также система управления NFT на основе стандарта ERC721, которая контролируется через голосование держателями токенов управления.

## Основные характеристики  
Токен управления (Governance Token):  
1. Пользователи могут приобретать токены управления, используя только USDT.  
2. Цена токена: 1 токен = 1 USDT.  
3. Чем больше токенов у пользователя, тем выше его вес голоса. Максимальный вес голоса — 5000 токенов.  
  
Голосование и предложения:  
1. Предложения могут создавать все пользователи, исключая предложения о разморозке.
2. На голосование по каждому предложению отводится 2 недели.  
3. После завершения голосования на выполнение предложения дается 1 неделя.  
  


## Контракты  
Важные (Нужны для деплоя):  
1. DAO.sol - контракт, включающий основной функционал DAO. (наследует от Market.sol)  
2. Market.sol - контракт, через который осуществляется покупка токенов.  
3. NFT.sol - ERC721 токен, которыйм управляет DAO.  
3. GOVR.sol - ERC20 токен управления.  
  
Для тестов:  
1. USDT.sol - ERC20 симуляция USDT  

## Инструкция к развертыванию  
1. Разверните контракт DAO, передайте адрес, чтобы сделать его владельцем.
2. Разверните контракт GOVR, передайте адрес, чтобы сделать его владельцем.
3. Разверните контракт NFT, передайте адрес DAO, чтобы сделать его владельцем.  
4. Отправьте некоторое количество ваших токенов на адрес DAO, чтобы пользователи смогли приобрести GOVR токены.




