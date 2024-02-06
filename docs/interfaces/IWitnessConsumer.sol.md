# IWitnessConsumer
[Git Source](https://github.com/WitnessCo/contracts-core/blob/5728ca18b700df861b9d2e351ca5ee93737de005/src/interfaces/IWitnessConsumer.sol)

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
function verifyProof(Proof calldata proof) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`proof`|`Proof`|The proof to be verified.|


### safeVerifyProof

Checks provenance of a leaf via Witness, returning a boolean instead of throwing for invalid proofs.

*This method is the same as `verifyProof`, except it returns false instead of throwing.*


```solidity
function safeVerifyProof(Proof calldata proof) external view returns (bool);
```

