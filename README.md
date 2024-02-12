# Witness Core Contracts [![Open in Gitpod][gitpod-badge]][gitpod] [![Github Actions][gha-badge]][gha] [![Foundry][foundry-badge]][foundry] [![License: MIT][license-badge]][license]

[gitpod]: https://gitpod.io/#https://github.com/WitnessCo/contracts-core
[gitpod-badge]: https://img.shields.io/badge/Gitpod-Open%20in%20Gitpod-FFB45B?logo=gitpod
[gha]: https://github.com/WitnessCo/contracts-core/actions
[gha-badge]: https://github.com/WitnessCo/contracts-core/actions/workflows/ci.yml/badge.svg
[foundry]: https://getfoundry.sh/
[foundry-badge]: https://img.shields.io/badge/Built%20with-Foundry-FFDB1C.svg
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
bun add github:WitnessCo/contracts-core
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
