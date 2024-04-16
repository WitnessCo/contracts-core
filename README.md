# Witness Core Contracts [![Open in Gitpod][gitpod-badge]][gitpod] [![Github Actions][gha-badge]][gha] [![License: BUSL-1.1][license-badge]][license]

[gitpod]: https://gitpod.io/#https://github.com/WitnessCo/contracts-core
[gitpod-badge]: https://img.shields.io/badge/Gitpod-Open%20in%20Gitpod-FFB45B?logo=gitpod
[gha]: https://github.com/WitnessCo/contracts-core/actions
[gha-badge]: https://github.com/WitnessCo/contracts-core/actions/workflows/ci.yml/badge.svg
[foundry]: https://getfoundry.sh/
[license]: https://spdx.org/licenses/BUSL-1.1.html
[license-badge]: https://img.shields.io/badge/License-BUSL-blue.svg

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

These values should be kept in-sync with the values provided [the client SDK](https://github.com/WitnessCo/client).

### Existing deployments

| Chain ID                    | Deployment Address                                                                                                                       |
| --------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| Mainnet (1)                 | [0x0000000e143f453f45B2E1cCaDc0f3CE21c2F06a](https://etherscan.io/address/0x0000000e143f453f45B2E1cCaDc0f3CE21c2F06a)                    |
| Base (8453)                 | [0x0000000e143f453f45B2E1cCaDc0f3CE21c2F06a](https://base.blockscout.com/address/0x0000000e143f453f45B2E1cCaDc0f3CE21c2F06a)             |
| Optimism (10)               | [0x0000000e143f453f45B2E1cCaDc0f3CE21c2F06a](https://optimism.blockscout.com/address/0x0000000e143f453f45B2E1cCaDc0f3CE21c2F06a)         |
| Sepolia (11155111)          | [0x00000008bcf12Eeb9E4162687D6D251f0F4e7FC2](https://eth-sepolia.blockscout.com/address/0x00000008bcf12Eeb9E4162687D6D251f0F4e7FC2)      |
| Base Sepolia (84532)        | [0x0000000159C8253802551eEaf8b475db1A50d712](https://base-sepolia.blockscout.com/address/0x0000000159C8253802551eEaf8b475db1A50d712)     |
| Optimism Sepolia (11155420) | [0x0000000a3fa5CFe56b202F376cCa7334c93aEB8b](https://optimism-sepolia.blockscout.com/address/0x0000000a3fa5CFe56b202F376cCa7334c93aEB8b) |
| Arbitrum Sepolia (421614)   | [0x00000006399970c8bdad606abD03b1712974E4eA](https://arbiscan.io/address/0x00000006399970c8bdad606abD03b1712974E4eA)                     |
| Gnosis Chiado (10200)       | [0x000000031C0d9df77F390CED953219E561B67089](https://gnosis-chiado.blockscout.com/address/0x000000031C0d9df77F390CED953219E561B67089)                     |

### Deploying on a new EVM chain

Deployment on a new chain involves a few steps:

1. Deploy a Gnosis Safe to be the `owner` param of the deployment (see below for guidance). Set this as the `OWNER_ADDRESS` value in your `.env` file.
2. Either reuse from below or calculate the CREATE2 deployment salt for the `Witness` contract via the following steps:
    ```sh
    cast create2 \
      --starts-with 0000000 \
      --init-code-hash $(bun run initcodehash) 
    ```
3. Ensure the following environment variables are all set:

   a. `DEPLOYMENT_PRIVATE_KEY` is set to a funded EOA

   b. `DEPLOYMENT_SALT` is set to the value calculated in step 2

4. Run `Deploy.s.sol`:
    ```sh
    forge script Deploy \
        --broadcast \
        -f=<YOUR_RPC_URL> \
        --watch
    ```
5. Note down the output values of the above steps into this README:
    - Any new Gnosis Safe that needed to be deployed, along with any new signers
    - Create2 factory and salt used for deployment if modified
    - Deployed address for `Witness.sol`
6. Add any additional `UPDATER_ROLE` addresses via the `grantRoles` method, called via the owner
7. Set up your checkpointer to submit updates to the new chain's `Witness.sol` address

You may want to take an additional step to verify the deployment on Etherscan or similar.

Note that because we're using a Create2 factory, the EOA you deploy from won't affect the resulting address.

#### Verifying the deployment

You can verify the source of the deployed contracts on an explorer like Blockscout. A sample command for Base is shown below:
```sh
forge verify-contract \
  --watch \
  --verifier=blockscout \
  --verifier-url=https://base.blockscout.com/api\? \
  --constructor-args $(cast abi-encode "constructor(address)" "0x10e859116a6388A7D0540a1bc1247Ae599d24F16") \
  0x0000000e143f453f45B2E1cCaDc0f3CE21c2F06a \
  Witness
```

### Reference Values

#### Owner Gnosis Safe Signers

All safes use the following singers under a 3-of-5 threshold:

- `0x9668aCbF23F0c4BC87B6D843EeEE35C20B91f643`
- `0x4f31617dc6f154cFfbA81eB5B9B307b442B3e661`
- `0x42EE0F3D7E54b6feF329fB6dc860634794832D2F`
- `0x3E8A785b44D28a9522d16E29158beA1c06D3A762`
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
| Base Sepolia (84532)        | [0xF554f6e21094aDB06680bD49aAB99b622c68CEc0](https://sepolia.basescan.org/address/0xf554f6e21094adb06680bd49aab99b622c68cec0)            |
| Optimism Sepolia (11155420) | [0xc6Fbdce6Ac57cEbF2032A318D92D0ffFc050A726](https://optimism-sepolia.blockscout.com/address/0xc6Fbdce6Ac57cEbF2032A318D92D0ffFc050A726) |
| Arbitrum Sepolia (421614)   | [0xd7db685f44CCDe17C966A16528d94942b497EBfE](https://arbiscan.io/address/0xd7db685f44CCDe17C966A16528d94942b497EBfE)                     |
| Gnosis Chiado (10200)       | [0xd7db685f44CCDe17C966A16528d94942b497EBfE](https://gnosis-chiado.blockscout.com/address/0xd7db685f44CCDe17C966A16528d94942b497EBfE)                     |

Note that Arbitrum Sepolia and Gnosis Chiado's owner is currently set to an EOA.  

#### Create2 Factory and Salt

When running the deploy script above, a factory address and salt are required for the create2 style deployment. The [default](https://github.com/Arachnid/deterministic-deployment-proxy) factory address is used for this, and the salt is calculated based on the set `OWNER_ADDRESS` with `bun run initcodehash`. Reference values used in previous deployments:

| Chain ID                    | Salt                                                               |
| --------------------------- | ------------------------------------------------------------------ |
| Mainnet (1)                 | 0xb3eaff343f96035800d8b917841ce9c526b3187bdbaa31ca1324d9403cfca860 |
| Base (8453)                 | 0xb3eaff343f96035800d8b917841ce9c526b3187bdbaa31ca1324d9403cfca860 |
| Optimism (10)               | 0xb3eaff343f96035800d8b917841ce9c526b3187bdbaa31ca1324d9403cfca860 |
| Sepolia (11155111)          | 0x25f297d9d4634e6d9b64a5762249df8c841977106db6cfc152c5c261722238e4 |
| Base Sepolia (84532)        | 0xbee48227768131701635040060883388e02d0cf71f757b851e6a9f3f5517e50d |
| Optimism Sepolia (11155420) | 0x1af2805263ccc6cb32de029263b124831c7b5666255f7a9c0356e2dfedb7b6e3 |
| Arbitrum Sepolia (421614)   | 0x425a725a8da61fb936f4693b36ebfba06e2244cb58173ba49ad6fc80976fa2c3 |
| Gnosis Chiado (10200)       | 0x0000000000000000000000000000000000000000000000005fc8112200000000 |


## Built with
- [Foundry](https://getfoundry.sh/)
- [Bun](https://bun.sh)
- [Solady](https://github.com/Vectorized/solady)
- [PRB Foundry Template](https://github.com/PaulRBerg/foundry-template)

## [Caveat Emptor](https://en.wikipedia.org/wiki/Caveat_emptor)

This is experimental software and is provided on an "as is" and "as available" basis. I do not give any warranties and
will not be liable for any loss, direct or indirect through continued use of this codebase.

## License

This project is licensed under BUSL-1.1.
