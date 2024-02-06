# ERC721P
[Git Source](https://github.com/WitnessCo/contracts-core/blob/af068ccc3b87576f36c3315270a9f29603465e11/src/ERC721P.sol)

**Inherits:**
ERC721, IERC721P

**Author:**
sina.eth

Simple example implementation of ERC721P.

*A simple implementation of IERC721P.*


## State Variables
### idToBridgeData
A mapping of tokenIds to their corresponding bridgeData.


```solidity
mapping(uint256 tokenId => bytes bridgeData) public idToBridgeData;
```


## Functions
### constructor

*Immutably sets the Witness address.*


```solidity
constructor(IWitness _witness) IERC721P(_witness);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_witness`|`IWitness`|The address that's used as the Witness to verify provenance against.|


### name

*Returns the token collection name.*


```solidity
function name() public pure virtual override returns (string memory);
```

### symbol

*Returns the token collection symbol.*


```solidity
function symbol() public pure virtual override returns (string memory);
```

### tokenURI

*Returns the Uniform Resource Identifier (URI) for token `id`.
For this sample implementation, the tokenURI is taken to immutably be the
bridgedTokenURI for the given tokenId and bridgeData.*


```solidity
function tokenURI(uint256 tokenId) public view virtual override returns (string memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenId`|`uint256`|The token to query the URI for.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`string`|uri The URI for the given token.|


### getProvenanceHash

*Returns the hash used for the provenance of the token's data.
In this sample implementation, we simply use the keccak256 hash of the bridgeData.*


```solidity
function getProvenanceHash(bytes calldata bridgeData) public view virtual override returns (bytes32);
```

### getBridgedOwner

Identifies the owner of the tokenId given its bridgeData.

*Returns the owner of the token given the bridgeData.
In this sample implementation, we simply decode the owner from the bridgeData.*


```solidity
function getBridgedOwner(bytes calldata bridgeData) public view virtual override returns (address owner);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`bridgeData`|`bytes`|The bridgeData to use to identify the owner.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`owner`|`address`|The owner of the token.|


### bridgedTokenURI

Returns the metadata URI for the tokenId given its bridgeData.

*Returns the metadata URI for the token, as if it were minted to this contract.
In this sample implementation, we simply decode the metadata URI from the bridgeData.*


```solidity
function bridgedTokenURI(bytes calldata bridgeData) public view virtual override returns (string memory uri);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`bridgeData`|`bytes`|The bridgeData to use to construct the metadata URI.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`uri`|`string`|tokenURI The metadata URI for the token.|


### bridge

Bridge the provenance of and mint an NFT.

*Bridges the provenance of and mints an NFT.
In this sample implementation, we simply store the bridgeData as the NFT's data.*


```solidity
function bridge(
    bytes calldata bridgeData,
    uint256 leafIndex,
    bytes32[] calldata leftProof,
    bytes32[] calldata rightProof,
    bytes32 targetRoot
)
    public
    override;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`bridgeData`|`bytes`|The data of the NFT, to be converted to a leaf.|
|`leafIndex`|`uint256`|The index of the leaf to be verified in the tree.|
|`leftProof`|`bytes32[]`|The left range of the proof.|
|`rightProof`|`bytes32[]`|The right range of the proof.|
|`targetRoot`|`bytes32`|The root of the tree the proof is being verified against.|


