~# Day 01 - User Storage

## Overview
User Storage is a Solidity smart contract project focused on storing, updating, retrieving, and deleting user profile data on-chain. It is a compact Hardhat exercise that demonstrates how persistent contract state behaves in a simple CRUD workflow.

## Smart Contract Purpose
The contract lets a user save personal data on-chain, view it later, update the stored record, and remove it when needed. The project is centered on basic state management and user-specific storage logic.

## Features
- **Profile Storage**: Store user information in contract storage.
- **Profile Retrieval**: Retrieve the saved user data.
- **Profile Updates**: Update an existing record.
- **Profile Deletion**: Delete stored user data.
- **Simplified Interface**: Keep the interface simple for basic transaction testing.

## Folder Structure & Contracts
The repository layout contains:

```
Day01/
├── contracts/
│   └── UserStorage.sol    # Core smart contract code
├── test/
│   └── UserStorage.ts            # Unit test suite
├── scripts/
│   └── send-op-tx.ts         # Script to execute operations
├── ignition/
│   └── modules/
│       └── UserStorage.ts # Hardhat Ignition deployment module
└── screenshots/              # Execution screenshots (deployment, tests)
```

### Purpose of the Contract
- **UserStorage**: Enables decentralized profile registries by storing personal data attributes (such as user details) directly in blockchain storage and offering CRUD functionalities.

## Concepts Practiced
- Solidity state variables and mappings.
- CRUD-style smart contract design.
- Hardhat project setup and Ignition deployment.
- TypeScript testing with Mocha, Chai, and ethers.
- Sepolia testnet deployment and verification.

## Project Summary
- **Language used**: Solidity 0.8.28 and TypeScript.
- **Tools used**: Hardhat, Hardhat Ignition, ethers v6, Mocha, Chai, and forge-std.
- **Contract name**: UserStorage.
- **Testing**: Hardhat test suite passed successfully.
- **Deployment status**: Deployed to Sepolia and verified on Blockscout.

## Deployment
- **Network**: Sepolia testnet.
- **Deployed contract address**: 0x3fbC6265AE7B43B1f315B710BB9E2da885a95a9a
- **Verification**: Successfully verified on Blockscout.

## Screenshots

**Intialization** : npx hardhat --init

![Hardhat](screenshots/hardhat.png)

**Deployemnt** : npx hardhat ignition deploy ./ignition/modules/UserStorage.ts --network sepolia --verify

![Deployment](screenshots/deploy.png)

**Testing Contracts** : npx hardhat test

![Test results](screenshots/test.png)
