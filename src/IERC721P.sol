// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { IWitness } from "./IWitness.sol";
import { WitnessProvenanceConsumer } from "./WitnessProvenanceConsumer.sol";

/// @title IERC721P
/// @author sina.eth
/// @notice Utility mixin for ERC721 adding provenance-related utility methods.
/// @dev ERC721-P[rovenance] is a 721 token that supports "bridging" provenance of lazy mints via Witness.
abstract contract IERC721P is WitnessProvenanceConsumer {
    /*//////////////////////////////////////////////////////////////////////////
                                     CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Immutably sets the Witness address.
    /// @param _witness The address that's used as the Witness to verify provenance against.
    constructor(IWitness _witness) WitnessProvenanceConsumer(_witness) { }

    /*//////////////////////////////////////////////////////////////
                         READ METHODS
    //////////////////////////////////////////////////////////////*/

    /// @notice Identifies the owner of the tokenId given its bridgeData.
    ///
    /// @dev May optionally throw when called for a token that already exists, but callers should not
    ///      rely on this and instead cross-check with whether the token has already been bridged.
    ///
    /// @param bridgeData The bridgeData to use to identify the owner.
    /// @return owner The owner of the token.
    function getBridgedOwner(bytes calldata bridgeData) public view virtual returns (address);

    /// @notice Returns the metadata URI for the tokenId given its bridgeData.
    ///
    /// @dev May optionally throw when called for a token that already exists, but callers should not
    ///      rely on this and instead cross-check with whether the token has already been bridged.
    ///
    /// @param bridgeData The bridgeData to use to construct the metadata URI.
    /// @return tokenURI The metadata URI for the token.
    function bridgedTokenURI(bytes calldata bridgeData) public view virtual returns (string memory);

    /// @notice Bridge the provenance of and mint an NFT.
    ///
    /// @param bridgeData The data of the NFT, to be converted to a leaf.
    /// @param leafIndex The index of the leaf to be verified in the tree.
    /// @param leftProof The left range of the proof.
    /// @param rightProof The right range of the proof.
    /// @param targetRoot The root of the tree the proof is being verified against.
    function bridge(
        bytes calldata bridgeData,
        uint256 leafIndex,
        bytes32[] calldata leftProof,
        bytes32[] calldata rightProof,
        bytes32 targetRoot
    )
        public
        virtual;
}
