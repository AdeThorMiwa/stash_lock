# Stash Contracts

Stash Contracts is a smart contract project built using the Hardhat framework. This repository contains the smart contracts and deployment scripts for the Stash protocol, which provides a decentralized protocol for saving and secure access management for digital assets on the blockchain.

## Features

- **Upgradeable Contracts**: Built with upgradeability in mind using proxy patterns.
- **Modular Design**: Contracts are organized into reusable modules for better maintainability and scalability.
- **Comprehensive Testing**: Includes a suite of tests to ensure the reliability and security of the contracts.
- **Deployment Automation**: Deployment scripts and configurations for multiple networks.

## Prerequisites

To work with this project, ensure you have the following installed:

- [Node.js](https://nodejs.org/) (v16 or later)
- [pnpm](https://pnpm.io/)
- [Hardhat](https://hardhat.org/)
- [Foundry](https://book.getfoundry.sh/) (for `anvil`)

## Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/your-repo/stash_it_contracts.git
   cd stash_it_contracts
   ```

2. Install dependencies:

   ```bash
   pnpm install
   ```

3. Set up the environment variables:

   - Create a `.env` file in the root directory.
   - Add the following variables to the `.env` file:
     ```env
     HARDHAT_NETWORK=hardhatMainnet
     LOCALHOST_DEPLOYER_PRIVATE_KEY=<your_deployer_private_key>
     LOCALHOST_OWNER_PRIVATE_KEY=<your_owner_private_key>
     ```

4. Start a local blockchain node (using `anvil`):
   ```bash
   pnpm start:node
   ```

## Usage

### Compile Contracts

To compile the smart contracts, run:

```bash
pnpm compile
```

### Deploy Contracts

To deploy the contracts using Hardhat Ignition, run:

```bash
pnpm deploy
```

To deploy all contracts:

```bash
pnpm deploy:all
```

### Run Tests

To execute the test suite, run:

```bash
pnpm test
```

### Scripts

The `scripts/` directory contains utility scripts for interacting with the deployed contracts. For example:

- `register-facets.ts`: Register facets for the diamond pattern.
- `send-op-tx.ts`: Send operational transactions.
- `update-proxy-admin.ts`: Update the proxy admin.
- `update-proxy-impl.ts`: Update the proxy implementation.

Run a script using Hardhat:

```bash
pnpm script scripts/<script-name>.ts
```

## Project Structure

```
├── contracts/          # Smart contract source files
├── artifacts/          # Compiled contract artifacts
├── cache/              # Hardhat cache
├── ignition/           # Deployment modules and artifacts
├── scripts/            # Utility scripts for contract interaction
├── tasks/              # Custom Hardhat tasks
├── test/               # Test files for the contracts
├── utils/              # Helper utilities for tests and scripts
├── hardhat.config.ts   # Hardhat configuration file
├── package.json        # Project dependencies and scripts
├── tsconfig.json       # TypeScript configuration
├── .env                # Environment variables
```

## Contributing

We welcome contributions to the Stash It Contracts project! To contribute:

1. Fork the repository.
2. Create a new branch for your feature or bugfix:
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. Make your changes and commit them:
   ```bash
   git commit -m "Add your message here"
   ```
4. Push your changes to your fork:
   ```bash
   git push origin feature/your-feature-name
   ```
5. Open a pull request to the `main` branch of this repository.


## Support

If you encounter any issues or have questions, feel free to open an issue in this repository.
