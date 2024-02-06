# WitnessConsumer

[Git Source](https://github.com/WitnessCo/contracts-core/blob/5728ca18b700df861b9d2e351ca5ee93737de005/src/WitnessConsumer.sol)

**Inherits:** IWitnessConsumer

**Author:** sina.eth

Utility mixin for contracts that want to consume provenance.

_See IWitnessConsumer.sol for more information._

## State Variables

### WITNESS

The Witness contract that this contract uses to verify provenance.

```solidity
IWitness public immutable WITNESS;
```

## Functions

### constructor

_Immutably sets the Witness address._

```solidity
constructor(IWitness _witness);
```

**Parameters**

| Name       | Type       | Description                                                          |
| ---------- | ---------- | -------------------------------------------------------------------- |
| `_witness` | `IWitness` | The address that's used as the Witness to verify provenance against. |

### getProvenanceHash

Maps the given bridgeData to its provenance hash representation for verification.

_A default implementation is given here, but it may be overridden by subclasses. Provenance hash refers to the hash that
Witness uses to verify the provenance of some data payload. Intuitively a provenance hash may be a hard-link from the
bridgeData, like a hash, or perhaps something more sophisticated for certain usecases._

```solidity
function getProvenanceHash(bytes calldata data) public view virtual returns (bytes32);
```

**Parameters**

| Name   | Type    | Description                                 |
| ------ | ------- | ------------------------------------------- |
| `data` | `bytes` | The data to be mapped to a provenance hash. |

**Returns**

| Name     | Type      | Description                                        |
| -------- | --------- | -------------------------------------------------- |
| `<none>` | `bytes32` | hash The provenanceHash corresponding to the data. |

### verifyProof

Checks provenance of a leaf via Witness.

_This method will throw if the proof is invalid, with a custom error describing how the verification failed._

```solidity
function verifyProof(Proof calldata proof) public view virtual;
```

**Parameters**

| Name    | Type    | Description               |
| ------- | ------- | ------------------------- |
| `proof` | `Proof` | The proof to be verified. |

### safeVerifyProof

Checks provenance of a leaf via Witness, returning a boolean instead of throwing for invalid proofs.

_This method is the same as `verifyProof`, except it returns false instead of throwing._

```solidity
function safeVerifyProof(Proof calldata proof) public view virtual returns (bool);
```
