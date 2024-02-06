// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { ERC721 } from "solady/tokens/ERC721.sol";

import { IWitness } from "./IWitness.sol";
import { WitnessProvenanceConsumer } from "./WitnessProvenanceConsumer.sol";
import { IERC721P } from "./IERC721P.sol";

/// @title ERC721P
/// @author sina.eth
/// @notice Simple example implementation of ERC721P.
/// @dev A simple implementation of IERC721P.
contract ERC721P is ERC721, IERC721P {
    /*//////////////////////////////////////////////////////////////////////////
                                   PUBLIC STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice A mapping of tokenIds to their corresponding bridgeData.
    mapping(uint256 => bytes) public idToBridgeData;

    /*//////////////////////////////////////////////////////////////////////////
                                     CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Immutably sets the Witness address.
    /// @param _witness The address that's used as the Witness to verify provenance against.
    constructor(IWitness _witness) IERC721P(_witness) { }

    /*//////////////////////////////////////////////////////////////
                READ METHODS - ERC721 OVERRIDES
    //////////////////////////////////////////////////////////////*/

    /// @dev Returns the token collection name.
    function name() public pure virtual override returns (string memory) {
        return "ERC721P";
    }

    /// @dev Returns the token collection symbol.
    function symbol() public pure virtual override returns (string memory) {
        return "ERC721P";
    }

    /// @dev Returns the Uniform Resource Identifier (URI) for token `id`.
    ///      For this sample implementation, the tokenURI is taken to immutably be the
    ///      bridgedTokenURI for the given tokenId and bridgeData.
    /// @param tokenId The token to query the URI for.
    /// @return uri The URI for the given token.
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        return this.bridgedTokenURI(idToBridgeData[tokenId]);
    }

    /*//////////////////////////////////////////////////////////////
                 IERC721P OVERRIDES
    //////////////////////////////////////////////////////////////*/

    /// @dev Returns the hash used for the provenance of the token's data.
    ///      In this sample implementation, we simply use the keccak256 hash of the bridgeData.
    /// @inheritdoc WitnessProvenanceConsumer
    function getProvenanceHash(bytes calldata bridgeData) public view virtual override returns (bytes32) {
        return keccak256(bridgeData);
    }

    /// @dev Returns the owner of the token given the bridgeData.
    ///      In this sample implementation, we simply decode the owner from the bridgeData.
    /// @inheritdoc IERC721P
    function getBridgedOwner(bytes calldata bridgeData) public view virtual override returns (address owner) {
        (owner,) = abi.decode(bridgeData, (address, string));
    }

    /// @dev Returns the metadata URI for the token, as if it were minted to this contract.
    ///      In this sample implementation, we simply decode the metadata URI from the bridgeData.
    /// @inheritdoc IERC721P
    function bridgedTokenURI(bytes calldata bridgeData) public view virtual override returns (string memory uri) {
        (, uri) = abi.decode(bridgeData, (address, string));
    }

    /// @dev Bridges the provenance of and mints an NFT.
    ///      In this sample implementation, we simply store the bridgeData as the NFT's data.
    /// @inheritdoc IERC721P
    function bridge(
        bytes calldata bridgeData,
        uint256 leafIndex,
        bytes32[] calldata leftProof,
        bytes32[] calldata rightProof,
        bytes32 targetRoot
    )
        public
        override
    {
        // NOTICE: this example implementation doesn't impose additional validity checks on the bridgeData.
        //         In a real implementation, you should consider using something like EIP712 or EIP191 for
        //         validating things like:
        //         - the data is allowed to be used in this contract
        //         - the data was intended to be used in this contract
        //         - the data hasn’t been used already
        //         - the data was intended to be used on this chain
        //         - the data was intended to be used by this version of the contract
        //         - etc.
        verifyProof(leafIndex, getProvenanceHash(bridgeData), leftProof, rightProof, targetRoot);
        idToBridgeData[leafIndex] = bridgeData;
        // Solady's `_safeMint` reverts if the token already exists.
        // @
        // https://github.com/Vectorized/solady/blob/dac54a8b24a2e6f598813a613bb3a272ea6dd4f3/src/tokens/ERC721.sol#L500
        _safeMint(getBridgedOwner(bridgeData), leafIndex);
    }
}
