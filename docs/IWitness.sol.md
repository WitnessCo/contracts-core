# IWitness

[Git Source](https://github.com/WitnessCo/contracts-core/blob/af068ccc3b87576f36c3315270a9f29603465e11/src/IWitness.sol)

**Author:** sina.eth

Interface for the core Witness smart contract.

_Base interface for the Witness contract._

## Functions

### rootCache

A mapping of checkpointed root hashes to their corresponding tree sizes.

param root The root hash for the checkpoint.

return treeSize The tree size corresponding to the root.

_This mapping is used to keep track of the tree size corresponding to when the contract accepted a given root hash._

_Returns 0 if the root hash is not in the mapping._

```solidity
function rootCache(bytes32 root) external view returns (uint256);
```

### currentRoot

The current root hash.

_This is the root hash of the most recently accepted update._

```solidity
function currentRoot() external view returns (bytes32);
```

### getCurrentTreeState

Helper util to get the current tree state.

```solidity
function getCurrentTreeState() external view returns (bytes32, uint256);
```

**Returns**

| Name     | Type      | Description                               |
| -------- | --------- | ----------------------------------------- |
| `<none>` | `bytes32` | currentRoot The current root of the tree. |
| `<none>` | `uint256` | treeSize The current size of the tree.    |

### verifyProof

Verifies a proof for a given leaf. Throws an error if the proof is invalid.

\*Notes:

- For invalid proofs, this method will throw with an error indicating why the proof failed to validate.
- The proof must validate against a checkpoint the contract has previously accepted.\*

```solidity
function verifyProof(
    uint256 index,
    bytes32 leaf,
    bytes32[] calldata leftRange,
    bytes32[] calldata rightRange,
    bytes32 targetRoot
)
    external
    view;
```

**Parameters**

| Name         | Type        | Description                                               |
| ------------ | ----------- | --------------------------------------------------------- |
| `index`      | `uint256`   | The index of the leaf to be verified in the tree.         |
| `leaf`       | `bytes32`   | The leaf to be verified.                                  |
| `leftRange`  | `bytes32[]` | The left range of the proof.                              |
| `rightRange` | `bytes32[]` | The right range of the proof.                             |
| `targetRoot` | `bytes32`   | The root of the tree the proof is being verified against. |

### safeVerifyProof

Verifies a proof for a given leaf, returning a boolean instead of throwing for invalid proofs.

_This method is a wrapper around `verifyProof` that catches any errors and returns false instead. The params and logic
are otherwise the same as `verifyProof`._

```solidity
function safeVerifyProof(
    uint256 index,
    bytes32 leaf,
    bytes32[] calldata leftRange,
    bytes32[] calldata rightRange,
    bytes32 targetRoot
)
    external
    view
    returns (bool isValid);
```

**Parameters**

| Name         | Type        | Description                                               |
| ------------ | ----------- | --------------------------------------------------------- |
| `index`      | `uint256`   | The index of the leaf to be verified in the tree.         |
| `leaf`       | `bytes32`   | The leaf to be verified.                                  |
| `leftRange`  | `bytes32[]` | The left range of the proof.                              |
| `rightRange` | `bytes32[]` | The right range of the proof.                             |
| `targetRoot` | `bytes32`   | The root of the tree the proof is being verified against. |

**Returns**

| Name      | Type   | Description                 |
| --------- | ------ | --------------------------- |
| `isValid` | `bool` | Whether the proof is valid. |

### updateTreeRoot

Updates the tree root to a larger tree.

\*Emits a RootUpdated event. Notes:

- A range proof is verified to ensure the new root is consistent with the previous root.
- Roots are stored in storage for easier retrieval in the future, along with the treeSize they correspond to.
  Requirements:
- `msg.sender` must be the contract owner.
- `newSize` must be greater than the current tree size.
- `oldRange` must correspond to the current tree root and size.
- size check must pass on `newRange`. After these checks are verified, the new root is calculated based on `oldRange`
  and `newRange`.\*

```solidity
function updateTreeRoot(uint256 newSize, bytes32[] calldata oldRange, bytes32[] calldata newRange) external;
```

**Parameters**

| Name       | Type        | Description                                                                         |
| ---------- | ----------- | ----------------------------------------------------------------------------------- |
| `newSize`  | `uint256`   | The size of the updated tree.                                                       |
| `oldRange` | `bytes32[]` | A compact range representing the current root.                                      |
| `newRange` | `bytes32[]` | A compact range representing the diff between oldRange and the new root's coverage. |

## Events

### RootUpdated

Emitted when the root is updated.

```solidity
event RootUpdated(bytes32 indexed newRoot, uint256 indexed newSize);
```

**Parameters**

| Name      | Type      | Description                        |
| --------- | --------- | ---------------------------------- |
| `newRoot` | `bytes32` | The newly accepted tree root hash. |
| `newSize` | `uint256` | The newly accepted tree size.      |
