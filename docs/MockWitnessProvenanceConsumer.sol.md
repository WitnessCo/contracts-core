# InvalidProof

[Git Source](https://github.com/WitnessCo/contracts-core/blob/af068ccc3b87576f36c3315270a9f29603465e11/src/MockWitnessConsumer.sol)

General error for invalid proof.

```solidity
error InvalidProof();
```

# MockWitnessConsumer

[Git Source](https://github.com/WitnessCo/contracts-core/blob/af068ccc3b87576f36c3315270a9f29603465e11/src/MockWitnessConsumer.sol)

**Inherits:** IWitnessConsumer

**Author:** sina.eth

Test and prototyping utility for contracts that want to consume provenance.

_See IWitnessConsumer.sol for more information._

## State Variables

### WITNESS

Read method for the Witness contract that this contract stores & uses to verify provenance.

```solidity
IWitness public constant WITNESS = IWitness(address(0));
```

### mockVal

_Value to return from mock verify functions._

```solidity
bool public mockVal = true;
```

## Functions

### setMockVal

_Function to set mockVal._

```solidity
function setMockVal(bool _mockVal) external;
```

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
function verifyProof(uint256, bytes32, bytes32[] calldata, bytes32[] calldata, bytes32) public view;
```

**Parameters**

| Name     | Type        | Description |
| -------- | ----------- | ----------- |
| `<none>` | `uint256`   |             |
| `<none>` | `bytes32`   |             |
| `<none>` | `bytes32[]` |             |
| `<none>` | `bytes32[]` |             |
| `<none>` | `bytes32`   |             |

### safeVerifyProof

Checks provenance of a leaf via Witness, returning a boolean instead of throwing for invalid proofs.

_This method is the same as `verifyProof`, except it returns false instead of throwing._

```solidity
function safeVerifyProof(
    uint256,
    bytes32,
    bytes32[] calldata,
    bytes32[] calldata,
    bytes32
)
    public
    view
    returns (bool);
```
