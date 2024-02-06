# decomposeNonZeroInterval

[Git Source](https://github.com/WitnessCo/contracts-core/blob/af068ccc3b87576f36c3315270a9f29603465e11/src/WitnessUtils.sol)

Helper for calculating range size for a non-zero-starting interval.

_The bitmath here decomposes the interval into two parts that in combination represent the compact range needed to
express the interval._

```solidity
function decomposeNonZeroInterval(uint256 begin, uint256 end) pure returns (uint256 left, uint256 right);
```

**Parameters**

| Name    | Type      | Description                                                    |
| ------- | --------- | -------------------------------------------------------------- |
| `begin` | `uint256` | The start of the interval of the range's coverage (inclusive). |
| `end`   | `uint256` | The end of the interval of the range's coverage (exclusive).   |

**Returns**

| Name    | Type      | Description                                         |
| ------- | --------- | --------------------------------------------------- |
| `left`  | `uint256` | Bitmap representing the left part of the interval.  |
| `right` | `uint256` | Bitmap representing the right part of the interval. |

# merge

[Git Source](https://github.com/WitnessCo/contracts-core/blob/af068ccc3b87576f36c3315270a9f29603465e11/src/WitnessUtils.sol)

Merges two compact ranges along a given seed node.

_Merge folds hashes in from leftRange and rightRange into seed in order to create a combined compact range. The merged
range is left + seed + right. leftRange is assumed to start its coverage at index 0._

```solidity
function merge(
    bytes32[] calldata leftRange,
    bytes32 seed,
    uint256 seedHeight,
    uint256 seedIndex,
    bytes32[] calldata rightRange,
    uint256 rightRangeEnd
)
    pure
    returns (bytes32[] calldata left, bytes32 newSeed, bytes32[] calldata right);
```

**Parameters**

| Name            | Type        | Description                            |
| --------------- | ----------- | -------------------------------------- |
| `leftRange`     | `bytes32[]` | The left compact range to merge.       |
| `seed`          | `bytes32`   | The seed node to merge along.          |
| `seedHeight`    | `uint256`   | The height of the seed node.           |
| `seedIndex`     | `uint256`   | The index of the seed node.            |
| `rightRange`    | `bytes32[]` | The right compact range to merge.      |
| `rightRangeEnd` | `uint256`   | The end of the right range's coverage. |

**Returns**

| Name      | Type        | Description                                    |
| --------- | ----------- | ---------------------------------------------- |
| `left`    | `bytes32[]` | The left portion of the merged compact range.  |
| `newSeed` | `bytes32`   | The new seed node of the merged range.         |
| `right`   | `bytes32[]` | The right portion of the merged compact range. |

# getRangeSizeForNonZeroBeginningInterval

[Git Source](https://github.com/WitnessCo/contracts-core/blob/af068ccc3b87576f36c3315270a9f29603465e11/src/WitnessUtils.sol)

Returns the expected size of a compact range needed to express a non-zero-starting interval.

```solidity
function getRangeSizeForNonZeroBeginningInterval(uint256 start, uint256 end) pure returns (uint256);
```

**Parameters**

| Name    | Type      | Description                                                    |
| ------- | --------- | -------------------------------------------------------------- |
| `start` | `uint256` | The start of the interval of the range's coverage (inclusive). |
| `end`   | `uint256` | The end of the interval of the range's coverage (exclusive).   |

**Returns**

| Name     | Type      | Description                                                                     |
| -------- | --------- | ------------------------------------------------------------------------------- |
| `<none>` | `uint256` | size The size of the compact range needed to express the interval [start, end). |

# hashToParent

[Git Source](https://github.com/WitnessCo/contracts-core/blob/af068ccc3b87576f36c3315270a9f29603465e11/src/WitnessUtils.sol)

Hashes two bytes32s together as into a merkle parent.

```solidity
function hashToParent(bytes32 left, bytes32 right) pure returns (bytes32 parent);
```

**Parameters**

| Name    | Type      | Description              |
| ------- | --------- | ------------------------ |
| `left`  | `bytes32` | The left child to hash.  |
| `right` | `bytes32` | The right child to hash. |

**Returns**

| Name     | Type      | Description      |
| -------- | --------- | ---------------- |
| `parent` | `bytes32` | The parent hash. |

# getRoot

[Git Source](https://github.com/WitnessCo/contracts-core/blob/af068ccc3b87576f36c3315270a9f29603465e11/src/WitnessUtils.sol)

Returns the root for a given compact range.

_This method "bags the peaks" of the compact range, folding in from R2L._

```solidity
function getRoot(bytes32[] calldata hashes) pure returns (bytes32 root);
```

**Parameters**

| Name     | Type        | Description                                                |
| -------- | ----------- | ---------------------------------------------------------- |
| `hashes` | `bytes32[]` | The hashes of the compact range to calculate the root for. |

**Returns**

| Name   | Type      | Description                    |
| ------ | --------- | ------------------------------ |
| `root` | `bytes32` | The root of the compact range. |

# getRootForMergedRange

[Git Source](https://github.com/WitnessCo/contracts-core/blob/af068ccc3b87576f36c3315270a9f29603465e11/src/WitnessUtils.sol)

Utility for calculating the root of a compact range provided in a gas-convenient representation.

```solidity
function getRootForMergedRange(
    bytes32[] calldata leftRange,
    bytes32 seed,
    bytes32[] calldata rightRange
)
    pure
    returns (bytes32 root);
```

**Parameters**

| Name         | Type        | Description                                       |
| ------------ | ----------- | ------------------------------------------------- |
| `leftRange`  | `bytes32[]` | The left portion of the compact range to merge.   |
| `seed`       | `bytes32`   | The middle portion of the compact range to merge. |
| `rightRange` | `bytes32[]` | The right portion of the compact range to merge.  |

**Returns**

| Name   | Type      | Description                               |
| ------ | --------- | ----------------------------------------- |
| `root` | `bytes32` | The calculated root of the compact range. |
