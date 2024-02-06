// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { IWitness } from "./IWitness.sol";
import { IWitnessProvenanceConsumer } from "./IWitnessProvenanceConsumer.sol";

/// General error for invalid proof.
error InvalidProof();

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
    function verifyProof(uint256, bytes32, bytes32[] calldata, bytes32[] calldata, bytes32) public view {
        if (!mockVal) revert InvalidProof();
    }

    /// @inheritdoc IWitnessProvenanceConsumer
    function safeVerifyProof(
        uint256,
        bytes32,
        bytes32[] calldata,
        bytes32[] calldata,
        bytes32
    )
        public
        view
        returns (bool)
    {
        return mockVal;
    }
}
