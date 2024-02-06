# InvalidProof
[Git Source](https://github.com/WitnessCo/contracts-core/blob/af068ccc3b87576f36c3315270a9f29603465e11/src/MockWitnessProvenanceConsumer.sol)

General error for invalid proof.


```solidity
error InvalidProof();
```


# MockWitnessProvenanceConsumer
[Git Source](https://github.com/WitnessCo/contracts-core/blob/af068ccc3b87576f36c3315270a9f29603465e11/src/MockWitnessProvenanceConsumer.sol)

**Inherits:**
IWitnessProvenanceConsumer

**Author:**
sina.eth

Test and prototyping utility for contracts that want to consume provenance.

*See IWitnessProvenanceConsumer.sol for more information.*


## State Variables
### WITNESS
Read method for the Witness contract that this contract stores & uses to verify provenance.


```solidity
IWitness public constant WITNESS = IWitness(address(0));
```


### mockVal
*Value to return from mock verify functions.*


```solidity
bool public mockVal = true;
```


## Functions
### setMockVal

*Function to set mockVal.*


```solidity
function setMockVal(bool _mockVal) external;
```

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
function verifyProof(uint256, bytes32, bytes32[] calldata, bytes32[] calldata, bytes32) public view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`||
|`<none>`|`bytes32`||
|`<none>`|`bytes32[]`||
|`<none>`|`bytes32[]`||
|`<none>`|`bytes32`||


### safeVerifyProof

Checks provenance of a leaf via Witness, returning a boolean instead of throwing for invalid proofs.

*This method is the same as `verifyProof`, except it returns false instead of throwing.*


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

