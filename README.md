# Witness Core Contracts [![Open in Gitpod][gitpod-badge]][gitpod] [![Github Actions][gha-badge]][gha] [![License: MIT][license-badge]][license]

[gitpod]: https://gitpod.io/#https://github.com/WitnessCo/contracts-core
[gitpod-badge]: https://img.shields.io/badge/Gitpod-Open%20in%20Gitpod-FFB45B?logo=gitpod
[gha]: https://github.com/WitnessCo/contracts-core/actions
[gha-badge]: https://github.com/WitnessCo/contracts-core/actions/workflows/ci.yml/badge.svg
[foundry]: https://getfoundry.sh/
[license]: https://opensource.org/licenses/MIT
[license-badge]: https://img.shields.io/badge/License-MIT-blue.svg

This repo contains the core smart contracts for Witness. This includes the contracts used by the operator to submit checkpoints, as well as utilities for reading from and interacting with Witness.

The repo is mostly a standard [forge](https://getfoundry.sh) repo but uses [Bun](https://bun.sh) for some utilities as well. Here's an outline of the repo:

```text
repo
├── broadcast
│   └── Historical foundry deployment artifacts
├── docs
│   └── Markdown docs generated from the natspec of the contracts
├── examples
│   └── Sample usages of the core contracts
├── scripts
│   └── Utilities for deploying the core contracts
├── src
│   ├── interfaces
│   │   └── Interfaces for the core contracts
│   ├── MockWitnessConsumer.sol
│   ├── Witness.sol
│   ├── WitnessConsumer.sol
│   └── WitnessUtils.sol
├── test
│   └── Solidity tests for the core contracts
└── ts
    └── Typescript code and utils for consumers of the contract
```

See the Witness docs at [https://docs.witness.co](https://docs.witness.co) for more information on Witness and these contracts.

## Getting Started

### NPM Install

It's recommended to install this via an NPM-ish package manager; eg:

```sh
bun add github:witnessco/contracts-core
```

You may need to set up a `remapping.txt` or similar to get your project's toolchain to detect the contracts:

```text
@witnessco/contracts-core=node_modules/@witnessco/contracts-core
```

### Forge Install

```sh
forge install WitnessCo/contracts-core
```

### Additional Dependencies

The contracts in this repo also depend on [Solady](https://github.com/Vectorized/solady) for various utilities. You may need to separately configure this depending on your environment and toolchain; see Solady's docs for more information.

## Usage

Witness's core contracts can be permissionlessly integrated with by other systems on or offchain. Offchain systems can leverage these contracts as a source of truth for verification, while onchain consumers can inherit from the `WitnessConsumer` contract for a more seamless integration.

See the [examples](./examples) directory for some sample usages of the core contracts.

## Development

Some frequently used commands:

```sh
# Install dependencies
bun install

# Build contracts and typescript
bun run build

# Clean the build artifacts and cache directories
bun clean

# Lint and format
bun lint

# Run tests (solidity only)
forge test

# Generate Typescript ABIs from build artifacts
bun run build && bun generate:abis

# Gererate docs to the `./docs` directory
bun generate:docs

# Coverage
forge coverage

# Coverage report
bun test:coverage:report

# Compute the CREATE2 initcode hash for a `Witness` contract.
export OWNER_ADDRESS=OWNER_ADDRESS_HERE
bun run initcodehash
```

## Deployments

If you need a deployment on a new chain, feel free to open an issue and we can help you. Additional information is provided below for reference as well.

### Existing deployments

| Chain ID                    | Deployment Address                         |
| --------------------------- | ------------------------------------------ |
| Mainnet (1)                 | 0xTODO                                     |
| Base (8453)                 | 0x                                         |
| Optimism (10)               | 0x                                         |
| Sepolia (11155111)          | 0x                                         |
| Base Sepolia (84532)        | 0x630f98e225829F1F632cdD206796e072a120F648 |
| Optimism Sepolia (11155420) | 0x                                         |

### Deploying on a new EVM chain

Deployment on a new chain involves a few steps:

1. Deploy a Gnosis Safe to be the `owner` param of the deployment (see below for guidance). Set this as the `OWNER_ADDRESS` value in your `.env` file.
2. Calculate the CREATE2 initcode hash for the `Witness` contract via the following:
```sh
bun run initcodehash
```
3. Set `DEPLOYMENT_PRIVATE_KEY`, `DEPLOYMENT_SALT`, and any of the explorer API key variables in your `.env` file
4. Run `Deploy.s.sol` with the `owner` constructor param, the create2 factory, and the salt set:
```sh
forge script Deploy \
  --broadcast \
  -f=<YOUR_RPC_URL> \
  --verify \
  --verifier=sourcify
```
5. Note down the resulting values into this README:
    - Any Gnosis Safe that needed to be deployed, along with any new signers
    - Create2 factory and salt used for deployment if modified
    - Deployed address for `Witness.sol`
6. Add any additional `UPDATER_ROLE` addresses via the `grantRoles` method, called via the owner
7. Set up your checkpointer to submit updates to the new chain's `Witness.sol` address
8. You're all set!

Note that because we're using a Create2 factory, the EOA you deploy from won't affect the resulting address.

### Reference Values

#### Owner Gnosis Safe Signers

All safes use the following singers under a 3-of-5 threshold:

- `0x9668aCbF23F0c4BC87B6D843EeEE35C20B91f643`
- `0x4f31617dc6f154cffba81eb5b9b307b442b3e661`
- `0x42EE0F3D7E54b6feF329fB6dc860634794832D2F`
- `0x3e8a785b44d28a9522d16e29158bea1c06d3a762`
- `0x2e6511E702a256b92Be25580803f93269a1b8E45`
- `0x72Ff26D9517324eEFA89A48B75c5df41132c4f54`

#### Owner Gnosis Safe Deployments

`Witness.sol`'s sole deployment parameter is an owner address, which is recommended to be set to a Gnosis Safe.

[Smold.app's MultiSafe](https://smold.app/safe) helps us get deterministic Safe addresses for supported chains. The supported chains are as follows:
- Mainnet (1)
- Base (8453)
- Optimism (10)

For these chains, given our EOA signers staying fixed across chains, the address for the deployed owner Gnosis Safe is `0x10e859116a6388A7D0540a1bc1247Ae599d24F16`.

For chains that the MultiSafe tool doesn't support, we can manually deploy Gnosis Safes without having the address consistent. All chains have their values listed below for reference:

| Chain ID                    | Owner Safe Address                                                                                                                       |
| --------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| Mainnet (1)                 | [0x10e859116a6388A7D0540a1bc1247Ae599d24F16](https://etherscan.io/address/0x10e859116a6388A7D0540a1bc1247Ae599d24F16)                    |
| Base (8453)                 | [0x10e859116a6388A7D0540a1bc1247Ae599d24F16](https://basescan.org/address/0x10e859116a6388A7D0540a1bc1247Ae599d24F16)                    |
| Optimism (10)               | [0x10e859116a6388A7D0540a1bc1247Ae599d24F16](https://optimistic.etherscan.io/address/0x10e859116a6388A7D0540a1bc1247Ae599d24F16)         |
| Sepolia (11155111)          | [0x71bA2A9b041C8597E468B5e630b0E43Eb87BDc83](https://sepolia.etherscan.io/address/0x71bA2A9b041C8597E468B5e630b0E43Eb87BDc83)            |
| Base Sepolia (84532)        | [0xf554f6e21094adb06680bd49aab99b622c68cec0](https://sepolia.basescan.org/address/0xf554f6e21094adb06680bd49aab99b622c68cec0)            |
| Optimism Sepolia (11155420) | [0xc22834581ebc8527d974f8a1c97e1bea4ef910bc](https://optimism-sepolia.blockscout.com/address/0xc22834581ebc8527d974f8a1c97e1bea4ef910bc) |

#### Create2 Factory and Salt

When running the deploy script above, a factory address and salt are required for the create2 style deployment. The [default](https://github.com/Arachnid/deterministic-deployment-proxy) factory address is used for this, and the salt is calculated based on the set `OWNER_ADDRESS` with `bun run initcodehash`. Reference values used in previous deployments:

| Chain ID                    | Salt                                                               |
| --------------------------- | ------------------------------------------------------------------ |
| Mainnet (1)                 | 0xTODO                                                             |
| Base (8453)                 | 0x                                                                 |
| Optimism (10)               | 0x                                                                 |
| Sepolia (11155111)          | 0x                                                                 |
| Base Sepolia (84532)        | 0x6a529534ed37e3d7f3e5109010c7d75b9710d0b998c405e3c92739ff5232a483 |
| Optimism Sepolia (11155420) | 0x                                                                 |


## Built with
- [Foundry](https://getfoundry.sh/)
- [Bun](https://bun.sh)
- [Solady](https://github.com/Vectorized/solady)
- [PRB Foundry Template](https://github.com/PaulRBerg/foundry-template)

## [Caveat Emptor](https://en.wikipedia.org/wiki/Caveat_emptor)

This is experimental software and is provided on an "as is" and "as available" basis. I do not give any warranties and
will not be liable for any loss, direct or indirect through continued use of this codebase.

## License

This project is licensed under MIT.
