# WitnessProvenanceConsumer
[Git Source](https://github.com/WitnessCo/contracts-core/blob/af068ccc3b87576f36c3315270a9f29603465e11/src/WitnessProvenanceConsumer.sol)

**Inherits:**
IWitnessProvenanceConsumer

**Author:**
sina.eth

Utility mixin for contracts that want to consume provenance.

*See IWitnessProvenanceConsumer.sol for more information.*


## State Variables
### WITNESS
The Witness contract that this contract uses to verify provenance.


```solidity
IWitness public immutable WITNESS;
```


## Functions
### constructor

*Immutably sets the Witness address.*


```solidity
constructor(IWitness _witness);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_witness`|`IWitness`|The address that's used as the Witness to verify provenance against.|


### getProvenanceHash

Maps the given bridgeData to its provenance hash representation for verification.

*A default implementation is given here, but it may be overridden by subclasses.
Provenance hash refers to the hash that Witness uses to verify the provenance of
some data payload. Intuitively a provenance hash may be a hard-link from the
bridgeData, like a hash, or perhaps something more sophisticated for certain usecases.*


```solidity
function getProvenanceHash(bytes calldata data) public view virtual returns (bytes32);
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
    public
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
    public
    view
    returns (bool);
```
