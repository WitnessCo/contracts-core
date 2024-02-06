// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { IWitness, Proof } from "./interfaces/IWitness.sol";
import { IWitnessProvenanceConsumer } from "./interfaces/IWitnessProvenanceConsumer.sol";

/// General error for invalid proof.
error InvalidMockProof();

/// @title MockWitnessProvenanceConsumer
/// @author sina.eth
/// @notice Test and prototyping utility for contracts that want to consume provenance.
/// @dev See IWitnessProvenanceConsumer.sol for more information.
abstract contract MockWitnessProvenanceConsumer is IWitnessProvenanceConsumer {
    /*//////////////////////////////////////////////////////////////////////////
                                   PUBLIC STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IWitnessProvenanceConsumer
    IWitness public constant WITNESS = IWitness(address(0));

    /// @dev Value to return from mock verify functions.
    bool public mockVal = true;

    /// @dev Function to set mockVal.
    function setMockVal(bool _mockVal) external {
        mockVal = _mockVal;
    }

    /// @inheritdoc IWitnessProvenanceConsumer
    function getProvenanceHash(bytes calldata data) public view virtual returns (bytes32) {
        return keccak256(data);
    }

    /// @inheritdoc IWitnessProvenanceConsumer
    function verifyProof(Proof calldata) public view {
        if (!mockVal) revert InvalidMockProof();
    }

    /// @inheritdoc IWitnessProvenanceConsumer
    function safeVerifyProof(Proof calldata) public view returns (bool) {
        return mockVal;
    }
}
