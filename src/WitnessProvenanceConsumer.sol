// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { IWitness } from "./interfaces/IWitness.sol";
import { IWitnessProvenanceConsumer } from "./interfaces/IWitnessProvenanceConsumer.sol";

/// @title WitnessProvenanceConsumer
/// @author sina.eth
/// @notice Utility mixin for contracts that want to consume provenance.
/// @dev See IWitnessProvenanceConsumer.sol for more information.
abstract contract WitnessProvenanceConsumer is IWitnessProvenanceConsumer {
    /*//////////////////////////////////////////////////////////////////////////
                                   PUBLIC STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice The Witness contract that this contract uses to verify provenance.
    /// @inheritdoc IWitnessProvenanceConsumer
    IWitness public immutable WITNESS;

    /*//////////////////////////////////////////////////////////////////////////
                                     CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Immutably sets the Witness address.
    /// @param _witness The address that's used as the Witness to verify provenance against.
    constructor(IWitness _witness) {
        WITNESS = _witness;
    }

    /*//////////////////////////////////////////////////////////////
                         READ METHODS
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IWitnessProvenanceConsumer
    function getProvenanceHash(bytes calldata data) public view virtual returns (bytes32) {
        return keccak256(data);
    }

    /// @inheritdoc IWitnessProvenanceConsumer
    function verifyProof(
        uint256 index,
        bytes32 leaf,
        bytes32[] calldata leftProof,
        bytes32[] calldata rightProof,
        bytes32 targetRoot
    )
        public
        view
    {
        WITNESS.verifyProof(index, leaf, leftProof, rightProof, targetRoot);
    }

    /// @inheritdoc IWitnessProvenanceConsumer
    function safeVerifyProof(
        uint256 index,
        bytes32 leaf,
        bytes32[] calldata leftProof,
        bytes32[] calldata rightProof,
        bytes32 targetRoot
    )
        public
        view
        returns (bool)
    {
        return WITNESS.safeVerifyProof(index, leaf, leftProof, rightProof, targetRoot);
    }
}
