# IWitnessProvenanceConsumer
[Git Source](https://github.com/WitnessCo/contracts-core/blob/af068ccc3b87576f36c3315270a9f29603465e11/src/IWitnessProvenanceConsumer.sol)

**Author:**
sina.eth

Utility mixin for contracts that want to consume provenance.

*See the core Witness.sol contract for more information.*


## Functions
### WITNESS

Read method for the Witness contract that this contract stores & uses to verify provenance.


```solidity
function WITNESS() external view returns (IWitness);
```

### getProvenanceHash

Maps the given bridgeData to its provenance hash representation for verification.

*A default implementation is given here, but it may be overridden by subclasses.
Provenance hash refers to the hash that Witness uses to verify the provenance of
some data payload. Intuitively a provenance hash may be a hard-link from the
bridgeData, like a hash, or perhaps something more sophisticated for certain usecases.*


```solidity
function getProvenanceHash(bytes calldata data) external view returns (bytes32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`data`|`bytes`|The data to be mapped to a provenance hash.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bytes32`|hash The provenanceHash corresponding to the data.|


### verifyProof

Checks provenance of a leaf via Witness.

*This method will throw if the proof is invalid, with a custom error
describing how the verification failed.*


```solidity
function verifyProof(
    uint256 index,
    bytes32 leaf,
    bytes32[] calldata leftProof,
    bytes32[] calldata rightProof,
    bytes32 targetRoot
)
    external
    view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`index`|`uint256`|The index of the leaf to be verified in the tree.|
|`leaf`|`bytes32`|The leaf to be verified.|
|`leftProof`|`bytes32[]`|The left range of the proof.|
|`rightProof`|`bytes32[]`|The right range of the proof.|
|`targetRoot`|`bytes32`|The root of the tree the proof is being verified against.|


### safeVerifyProof

Checks provenance of a leaf via Witness, returning a boolean instead of throwing for invalid proofs.

*This method is the same as `verifyProof`, except it returns false instead of throwing.*


```solidity
function safeVerifyProof(
    uint256 index,
    bytes32 leaf,
    bytes32[] calldata leftProof,
    bytes32[] calldata rightProof,
    bytes32 targetRoot
)
    external
    view
    returns (bool);
```
