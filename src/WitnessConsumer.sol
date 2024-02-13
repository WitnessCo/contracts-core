// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IWitness, Proof } from "./interfaces/IWitness.sol";
import { IWitnessConsumer } from "./interfaces/IWitnessConsumer.sol";

/// @title WitnessConsumer
/// @author sina.eth
/// @custom:coauthor runtheblocks.eth
/// @notice Utility mixin for contracts that want to consume provenance.
/// @dev See IWitnessConsumer.sol for more information.
abstract contract WitnessConsumer is IWitnessConsumer {
    /*//////////////////////////////////////////////////////////////////////////
                                   PUBLIC STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice The Witness contract that this contract uses to verify provenance.
    /// @inheritdoc IWitnessConsumer
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

    /// @inheritdoc IWitnessConsumer
    function getProvenanceHash(bytes calldata data) public view virtual returns (bytes32) {
        return keccak256(data);
    }

    /// @inheritdoc IWitnessConsumer
    function verifyProof(Proof calldata proof) public view virtual {
        WITNESS.verifyProof(proof);
    }

    /// @inheritdoc IWitnessConsumer
    function safeVerifyProof(Proof calldata proof) public view virtual returns (bool) {
        return WITNESS.safeVerifyProof(proof);
    }
}
