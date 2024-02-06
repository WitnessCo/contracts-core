# InvalidProofBadRightRange
[Git Source](https://github.com/WitnessCo/contracts-core/blob/5728ca18b700df861b9d2e351ca5ee93737de005/src/interfaces/IWitness.sol)


```solidity
error InvalidProofBadRightRange();
```


# InvalidUpdateOldRangeMismatchWrongCurrentRoot
[Git Source](https://github.com/WitnessCo/contracts-core/blob/5728ca18b700df861b9d2e351ca5ee93737de005/src/interfaces/IWitness.sol)


```solidity
error InvalidUpdateOldRangeMismatchWrongCurrentRoot();
```


# InvalidUpdateNewRangeMismatchWrongLength
[Git Source](https://github.com/WitnessCo/contracts-core/blob/5728ca18b700df861b9d2e351ca5ee93737de005/src/interfaces/IWitness.sol)


```solidity
error InvalidUpdateNewRangeMismatchWrongLength();
```


# InvalidProofBadLeftRange
[Git Source](https://github.com/WitnessCo/contracts-core/blob/5728ca18b700df861b9d2e351ca5ee93737de005/src/interfaces/IWitness.sol)


```solidity
error InvalidProofBadLeftRange();
```


# InvalidProofLeafIdxOutOfBounds
[Git Source](https://github.com/WitnessCo/contracts-core/blob/5728ca18b700df861b9d2e351ca5ee93737de005/src/interfaces/IWitness.sol)

Proof verification errors.


```solidity
error InvalidProofLeafIdxOutOfBounds();
```


# IWitness
[Git Source](https://github.com/WitnessCo/contracts-core/blob/5728ca18b700df861b9d2e351ca5ee93737de005/src/interfaces/IWitness.sol)

**Author:**
sina.eth

Interface for the core Witness smart contract.

*Base interface for the Witness contract.*


## Functions
### currentRoot

The current root hash.

*This is the root hash of the most recently accepted update.*


```solidity
function currentRoot() external view returns (bytes32);
```

### rootInfo

A Mapping of checkpointed root hashes to their corresponding tree data.


```solidity
function rootInfo(bytes32 root) external view returns (RootInfo memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`root`|`bytes32`|The root hash for the checkpoint.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`RootInfo`|info The `RootInfo` struct containing info about the root hash checkpoint.|


### rootCache

A mapping of checkpointed root hashes to their corresponding tree sizes.

*This mapping is used to keep track of the tree size corresponding to when
the contract accepted a given root hash.*

*Returns 0 if the root hash is not in the mapping.*


```solidity
function rootCache(bytes32 root) external view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`root`|`bytes32`|The root hash for the checkpoint.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|treeSize The tree size corresponding to the root.|


### getCurrentTreeState

Helper util to get the current tree state.


```solidity
function getCurrentTreeState() external view returns (bytes32, uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bytes32`|currentRoot The current root of the tree.|
|`<none>`|`uint256`|treeSize The current size of the tree.|


### getLastUpdateTime

Helper util to get the last `block.timestamp` the tree was updated.


```solidity
function getLastUpdateTime() external view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|timestamp The `block.timestamp` the update was made.|


### getLastUpdateBlock

Helper util to get the last `block.number` the tree was updated.


```solidity
function getLastUpdateBlock() external view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|block The `block.timestamp` the update was made.|


### verifyProof

Verifies a proof for a given leaf. Throws an error if the proof is invalid.

*Notes:
- For invalid proofs, this method will throw with an error indicating why the proof failed to validate.
- The proof must validate against a checkpoint the contract has previously accepted.*


```solidity
function verifyProof(Proof calldata proof) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`proof`|`Proof`|The proof to be verified.|


### safeVerifyProof

Verifies a proof for a given leaf, returning a boolean instead of throwing for invalid proofs.

*This method is a wrapper around `verifyProof` that catches any errors and returns false instead.
The params and logic are otherwise the same as `verifyProof`.*


```solidity
function safeVerifyProof(Proof calldata proof) external view returns (bool isValid);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`proof`|`Proof`|The proof to be verified.|


### updateTreeRoot

Updates the tree root to a larger tree.

*Emits a RootUpdated event.
Notes:
- A range proof is verified to ensure the new root is consistent with the previous root.
- Roots are stored in storage for easier retrieval in the future, along with the treeSize
they correspond to.
Requirements:
- `msg.sender` must be the contract owner.
- `newSize` must be greater than the current tree size.
- `oldRange` must correspond to the current tree root and size.
- size check must pass on `newRange`.
After these checks are verified, the new root is calculated based on `oldRange` and `newRange`.*


```solidity
function updateTreeRoot(uint256 newSize, bytes32[] calldata oldRange, bytes32[] calldata newRange) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newSize`|`uint256`|The size of the updated tree.|
|`oldRange`|`bytes32[]`|A compact range representing the current root.|
|`newRange`|`bytes32[]`|A compact range representing the diff between oldRange and the new root's coverage.|


## Events
### RootUpdated
Emitted when the root is updated.


```solidity
event RootUpdated(bytes32 indexed newRoot, uint256 indexed newSize);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newRoot`|`bytes32`|The newly accepted tree root hash.|
|`newSize`|`uint256`|The newly accepted tree size.|


# InvalidUpdateOldRangeMismatchWrongLength
[Git Source](https://github.com/WitnessCo/contracts-core/blob/5728ca18b700df861b9d2e351ca5ee93737de005/src/interfaces/IWitness.sol)


```solidity
error InvalidUpdateOldRangeMismatchWrongLength();
```


# InvalidUpdateTreeSizeMustGrow
[Git Source](https://github.com/WitnessCo/contracts-core/blob/5728ca18b700df861b9d2e351ca5ee93737de005/src/interfaces/IWitness.sol)


```solidity
error InvalidUpdateTreeSizeMustGrow();
```


# InvalidProofUnrecognizedRoot
[Git Source](https://github.com/WitnessCo/contracts-core/blob/5728ca18b700df861b9d2e351ca5ee93737de005/src/interfaces/IWitness.sol)


```solidity
error InvalidProofUnrecognizedRoot();
```


# RootInfo
[Git Source](https://github.com/WitnessCo/contracts-core/blob/5728ca18b700df861b9d2e351ca5ee93737de005/src/interfaces/IWitness.sol)

A packed 32 byte value containing info for any given root.


```solidity
struct RootInfo {
    uint176 treeSize;
    uint40 timestamp;
    uint40 height;
}
```


# Proof
[Git Source](https://github.com/WitnessCo/contracts-core/blob/5728ca18b700df861b9d2e351ca5ee93737de005/src/interfaces/IWitness.sol)

A proof for a given leaf in a merkle mountain range.


```solidity
struct Proof {
    uint256 index;
    bytes32 leaf;
    bytes32[] leftRange;
    bytes32[] rightRange;
    bytes32 targetRoot;
}
```


# InvalidUpdateOldRangeMismatchShouldBeEmpty
[Git Source](https://github.com/WitnessCo/contracts-core/blob/5728ca18b700df861b9d2e351ca5ee93737de005/src/interfaces/IWitness.sol)

Tree update errors.


```solidity
error InvalidUpdateOldRangeMismatchShouldBeEmpty();
```

