// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import { IWitness, Proof } from "./interfaces/IWitness.sol";
import { IWitnessConsumer } from "./interfaces/IWitnessConsumer.sol";

/// @title WitnessConsumer
/// @author sina.eth
/// @custom:coauthor runtheblocks.eth
/// @notice Utility mixin for contracts that want to consume provenance.
/// @dev See IWitnessConsumer.sol for more information.
abstract contract WitnessConsumer is IWitnessConsumer {
    /*//////////////////////////////////////////////////////////////
                         READ METHODS
    //////////////////////////////////////////////////////////////*/

    /// @notice The Witness contract that this contract uses to verify provenance.
    /// @inheritdoc IWitnessConsumer
    function WITNESS() public view virtual returns (IWitness);

    /// @inheritdoc IWitnessConsumer
    function getProvenanceHash(bytes calldata data) external view virtual returns (bytes32) {
        return keccak256(data);
    }

    /// @inheritdoc IWitnessConsumer
    function verifyProof(Proof calldata proof) external view virtual {
        WITNESS().verifyProof(proof);
    }

    /// @inheritdoc IWitnessConsumer
    function safeVerifyProof(Proof calldata proof) external view virtual returns (bool) {
        return WITNESS().safeVerifyProof(proof);
    }
}
