# IERC721P
[Git Source](https://github.com/WitnessCo/contracts-core/blob/af068ccc3b87576f36c3315270a9f29603465e11/src/IERC721P.sol)

**Inherits:**
WitnessProvenanceConsumer

**Author:**
sina.eth

Utility mixin for ERC721 adding provenance-related utility methods.

*ERC721-P[rovenance] is a 721 token that supports "bridging" provenance of lazy mints via Witness.*


## Functions
### constructor

*Immutably sets the Witness address.*


```solidity
constructor(IWitness _witness) WitnessProvenanceConsumer(_witness);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_witness`|`IWitness`|The address that's used as the Witness to verify provenance against.|


### getBridgedOwner

Identifies the owner of the tokenId given its bridgeData.

*May optionally throw when called for a token that already exists, but callers should not
rely on this and instead cross-check with whether the token has already been bridged.*


```solidity
function getBridgedOwner(bytes calldata bridgeData) public view virtual returns (address);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`bridgeData`|`bytes`|The bridgeData to use to identify the owner.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|owner The owner of the token.|


### bridgedTokenURI

Returns the metadata URI for the tokenId given its bridgeData.

*May optionally throw when called for a token that already exists, but callers should not
rely on this and instead cross-check with whether the token has already been bridged.*


```solidity
function bridgedTokenURI(bytes calldata bridgeData) public view virtual returns (string memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`bridgeData`|`bytes`|The bridgeData to use to construct the metadata URI.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`string`|tokenURI The metadata URI for the token.|


### bridge

Bridge the provenance of and mint an NFT.


```solidity
function bridge(
    bytes calldata bridgeData,
    uint256 leafIndex,
    bytes32[] calldata leftProof,
    bytes32[] calldata rightProof,
    bytes32 targetRoot
)
    public
    virtual;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`bridgeData`|`bytes`|The data of the NFT, to be converted to a leaf.|
|`leafIndex`|`uint256`|The index of the leaf to be verified in the tree.|
|`leftProof`|`bytes32[]`|The left range of the proof.|
|`rightProof`|`bytes32[]`|The right range of the proof.|
|`targetRoot`|`bytes32`|The root of the tree the proof is being verified against.|


