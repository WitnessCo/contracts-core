# Witness

[Git Source](https://github.com/WitnessCo/contracts-core/blob/5728ca18b700df861b9d2e351ca5ee93737de005/src/Witness.sol)

**Inherits:** IWitness, OwnableRoles

**Author:** sina.eth

The core Witness smart contract.

_The Witness smart contract tracks a merkle mountain range and enforces that any newly posted merkle root is consistent
with the previous root._

## State Variables

### UPDATER_ROLE

```solidity
uint256 public constant UPDATER_ROLE = _ROLE_0;
```

### currentRoot

The current root hash.

_This is the root hash of the most recently accepted update._

```solidity
bytes32 public currentRoot;
```

### \_rootInfo

```solidity
mapping(bytes32 root => RootInfo cache) internal _rootInfo;
```

## Functions

### rootInfo

A Mapping of checkpointed root hashes to their corresponding tree data.

```solidity
function rootInfo(bytes32 root) public view virtual returns (RootInfo memory);
```

**Parameters**

| Name   | Type      | Description                       |
| ------ | --------- | --------------------------------- |
| `root` | `bytes32` | The root hash for the checkpoint. |

**Returns**

| Name     | Type       | Description                                                                |
| -------- | ---------- | -------------------------------------------------------------------------- |
| `<none>` | `RootInfo` | info The `RootInfo` struct containing info about the root hash checkpoint. |

### rootCache

A mapping of checkpointed root hashes to their corresponding tree sizes.

_This mapping is used to keep track of the tree size corresponding to when the contract accepted a given root hash._

```solidity
function rootCache(bytes32 root) public view virtual returns (uint256);
```

**Parameters**

| Name   | Type      | Description                       |
| ------ | --------- | --------------------------------- |
| `root` | `bytes32` | The root hash for the checkpoint. |

**Returns**

| Name     | Type      | Description                                       |
| -------- | --------- | ------------------------------------------------- |
| `<none>` | `uint256` | treeSize The tree size corresponding to the root. |

### constructor

_Emits an {OwnableRoles.OwnershipTransferred} event._

```solidity
constructor(address owner);
```

**Parameters**

| Name    | Type      | Description                                                   |
| ------- | --------- | ------------------------------------------------------------- |
| `owner` | `address` | The address that should be set as the initial contract owner. |

### getCurrentTreeState

Helper util to get the current tree state.

```solidity
function getCurrentTreeState() external view virtual returns (bytes32, uint256);
```

**Returns**

| Name     | Type      | Description                               |
| -------- | --------- | ----------------------------------------- |
| `<none>` | `bytes32` | currentRoot The current root of the tree. |
| `<none>` | `uint256` | treeSize The current size of the tree.    |

### getLastUpdateTime

Helper util to get the last `block.timestamp` the tree was updated.

```solidity
function getLastUpdateTime() external view virtual returns (uint256);
```

**Returns**

| Name     | Type      | Description                                          |
| -------- | --------- | ---------------------------------------------------- |
| `<none>` | `uint256` | timestamp The `block.timestamp` the update was made. |

### getLastUpdateBlock

Helper util to get the last `block.number` the tree was updated.

```solidity
function getLastUpdateBlock() external view virtual returns (uint256);
```

**Returns**

| Name     | Type      | Description                                      |
| -------- | --------- | ------------------------------------------------ |
| `<none>` | `uint256` | block The `block.timestamp` the update was made. |

### verifyProof

Verifies a proof for a given leaf. Throws an error if the proof is invalid.

\*Notes:

- For invalid proofs, this method will throw with an error indicating why the proof failed to validate.
- The proof must validate against a checkpoint the contract has previously accepted.\*

```solidity
function verifyProof(Proof calldata proof) external view virtual;
```

**Parameters**

| Name    | Type    | Description               |
| ------- | ------- | ------------------------- |
| `proof` | `Proof` | The proof to be verified. |

### safeVerifyProof

Verifies a proof for a given leaf, returning a boolean instead of throwing for invalid proofs.

_This method is a wrapper around `verifyProof` that catches any errors and returns false instead. The params and logic
are otherwise the same as `verifyProof`._

```solidity
function safeVerifyProof(Proof calldata proof) external view returns (bool isValid);
```

**Parameters**

| Name    | Type    | Description               |
| ------- | ------- | ------------------------- |
| `proof` | `Proof` | The proof to be verified. |

### updateTreeRoot

Updates the tree root to a larger tree.

\*Emits a {RootUpdated} event. Notes:

- A range proof is verified to ensure the new root is consistent with the previous root.
- Roots are stored in storage for easier retrieval in the future, along with the treeSize they correspond to.
  Requirements:
- `msg.sender` must be the contract owner.
- `newSize` must be greater than the current tree size.
- `oldRange` must correspond to the current tree root and size.
- size check must pass on `newRange`. After these checks are verified, the new root is calculated based on `oldRange`
  and `newRange`.\*

```solidity
function updateTreeRoot(
    uint256 newSize,
    bytes32[] calldata oldRange,
    bytes32[] calldata newRange
)
    external
    virtual
    onlyRoles(UPDATER_ROLE);
```

**Parameters**

| Name       | Type        | Description                                                                         |
| ---------- | ----------- | ----------------------------------------------------------------------------------- |
| `newSize`  | `uint256`   | The size of the updated tree.                                                       |
| `oldRange` | `bytes32[]` | A compact range representing the current root.                                      |
| `newRange` | `bytes32[]` | A compact range representing the diff between oldRange and the new root's coverage. |

### fallback

_Used for L2 calldata optimization. For efficiency, this function will directly return the results, terminating the
context. If called internally, it must be called at the end of the function._

```solidity
fallback() external virtual;
```
