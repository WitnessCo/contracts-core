// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { IWitness, Proof } from "./interfaces/IWitness.sol";
import { IWitnessConsumer } from "./interfaces/IWitnessConsumer.sol";

/// General error for invalid proof.
error InvalidMockProof();

/// @title MockWitnessConsumer
/// @author sina.eth
/// @notice Test and prototyping utility for contracts that want to consume provenance.
/// @dev See IWitnessConsumer.sol for more information.
abstract contract MockWitnessConsumer is IWitnessConsumer {
    /*//////////////////////////////////////////////////////////////////////////
                                   PUBLIC STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IWitnessConsumer
    IWitness public constant WITNESS = IWitness(address(0));

    /// @dev Value to return from mock verify functions.
    bool public mockVal = true;

    /// @dev Function to set mockVal.
    function setMockVal(bool _mockVal) external {
        mockVal = _mockVal;
    }

    /// @inheritdoc IWitnessConsumer
    function getProvenanceHash(bytes calldata data) public view virtual returns (bytes32) {
        return keccak256(data);
    }

    /// @inheritdoc IWitnessConsumer
    function verifyProof(Proof calldata) public view {
        if (!mockVal) revert InvalidMockProof();
    }

    /// @inheritdoc IWitnessConsumer
    function safeVerifyProof(Proof calldata) public view returns (bool) {
        return mockVal;
    }
}
