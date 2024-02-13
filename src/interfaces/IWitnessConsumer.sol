// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IWitness, Proof } from "./IWitness.sol";

/// @title IWitnessConsumer
/// @author sina.eth
/// @custom:coauthor runtheblocks.eth
/// @notice Utility mixin for contracts that want to consume provenance.
/// @dev See the core Witness.sol contract for more information.
interface IWitnessConsumer {
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
    /// @param proof The proof to be verified.
    function verifyProof(Proof calldata proof) external view;

    /// @notice Checks provenance of a leaf via Witness, returning a boolean instead of throwing for invalid proofs.
    ///
    /// @dev This method is the same as `verifyProof`, except it returns false instead of throwing.
    function safeVerifyProof(Proof calldata proof) external view returns (bool);
}
