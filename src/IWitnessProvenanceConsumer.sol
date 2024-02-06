// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { IWitness } from "./IWitness.sol";

/// @title IWitnessProvenanceConsumer
/// @author sina.eth
/// @notice Utility mixin for contracts that want to consume provenance.
/// @dev See the core Witness.sol contract for more information.
interface IWitnessProvenanceConsumer {
    /*//////////////////////////////////////////////////////////////////////////
                                   PUBLIC STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Read method for the Witness contract that this contract stores & uses to verify provenance.
    function WITNESS() external view returns (IWitness);

    /*//////////////////////////////////////////////////////////////
                         READ METHODS
    //////////////////////////////////////////////////////////////*/

    /// @notice Maps the given bridgeData to its provenance hash representation for verification.
    ///
    /// @dev A default implementation is given here, but it may be overridden by subclasses.
    ///
    ///      Provenance hash refers to the hash that Witness uses to verify the provenance of
    ///      some data payload. Intuitively a provenance hash may be a hard-link from the
    ///      bridgeData, like a hash, or perhaps something more sophisticated for certain usecases.
    ///
    /// @param data The data to be mapped to a provenance hash.
    /// @return hash The provenanceHash corresponding to the data.
    function getProvenanceHash(bytes calldata data) external view returns (bytes32);

    /// @notice Checks provenance of a leaf via Witness.
    ///
    /// @dev This method will throw if the proof is invalid, with a custom error
    ///      describing how the verification failed.
    ///
    /// @param index The index of the leaf to be verified in the tree.
    /// @param leaf The leaf to be verified.
    /// @param leftProof The left range of the proof.
    /// @param rightProof The right range of the proof.
    /// @param targetRoot The root of the tree the proof is being verified against.
    function verifyProof(
        uint256 index,
        bytes32 leaf,
        bytes32[] calldata leftProof,
        bytes32[] calldata rightProof,
        bytes32 targetRoot
    )
        external
        view;

    /// @notice Checks provenance of a leaf via Witness, returning a boolean instead of throwing for invalid proofs.
    ///
    /// @dev This method is the same as `verifyProof`, except it returns false instead of throwing.
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
}
