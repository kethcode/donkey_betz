# Sample Hardhat Project

This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, and a script that deploys that contract.

Try running some of the following tasks:

```shell
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat run scripts/deploy.js
```


Identity in 3 contracts:
    1. Create User
        a. UserSignup struct to map to user
        b. verify that username does not == address(0)
        c. verify that email does not == address(0)
        d. verity that wallet does not == address(0)
    2. Roles
    3. Mint NFT




 <!-- TO DO: 
Token contract: This smart contract is responsible for managing the token economy of your dapp. This can include creating, issuing and managing a custom token, or using an existing one. -->


<!-- TO DO:
To be added later
Market contract: This smart contract is responsible for managing the market prediction aspect of your dapp. This can include creating markets, placing bets, tracking outcomes and settling bets. -->


<!-- TO DO:
Token vault contract: This smart contract is responsible for holding and managing the token funds, it can include locking, releasing and withdrawing the tokens for the different use cases. -->



<!-- TO DO:
Oracle contract: This smart contract is responsible for providing real-world information to your smart contracts. In the case of prediction markets, the oracle contract will be responsible for providing the outcome of the events on which the market is based. -->



<!-- TO DO: 
    Governance contract: This smart contract is responsible for handling the governance of the dapp, it allows users to propose, vote and execute on changes to the dapp. -->



<!-- TO DO:
Escrow contract: This smart contract is responsible for holding and managing the funds in escrow while the outcome of the market is not known, and releasing the funds to the winning party once the market's outcome is known. -->



<!-- 
Add storage for user information: You will need to add storage to the contract to store information about each user, such as their name, email address, phone number, etc. You can use a struct to store this information, and use a mapping to map a user's Ethereum address to their struct. -->


