// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { LibBit } from "solady/utils/LibBit.sol";
import { OwnableRoles } from "solady/auth/OwnableRoles.sol";

import {
    InvalidProofBadLeftRange,
    InvalidProofBadRightRange,
    InvalidProofLeafIdxOutOfBounds,
    InvalidProofUnrecognizedRoot,
    InvalidUpdateNewRangeMismatchWrongLength,
    InvalidUpdateOldRangeMismatchShouldBeEmpty,
    InvalidUpdateOldRangeMismatchWrongCurrentRoot,
    InvalidUpdateOldRangeMismatchWrongLength,
    InvalidUpdateTreeSizeMustGrow,
    IWitness,
    Proof,
    RootCache
} from "./interfaces/IWitness.sol";
import { getRangeSizeForNonZeroBeginningInterval, getRoot, getRootForMergedRange, merge } from "./WitnessUtils.sol";

/// @title Witness
/// @author sina.eth
/// @notice The core Witness smart contract.
/// @dev The Witness smart contract tracks a merkle mountain range and enforces
///      that any newly posted merkle root is consistent with the previous root.
contract Witness is IWitness, OwnableRoles {
    using LibBit for uint256;

    /*//////////////////////////////////////////////////////////////////////////
                                   CONSTANTS
    //////////////////////////////////////////////////////////////////////////*/
    uint256 public constant UPDATER_ROLE = _ROLE_0;

    /*//////////////////////////////////////////////////////////////////////////
                                MUTABLE STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice The current root hash.
    /// @inheritdoc IWitness
    bytes32 public currentRoot;

    /// @notice A mapping of checkpointed root hashes to their corresponding tree sizes.
    mapping(bytes32 rootHash => RootCache cache) internal _rootCache;

    /// @inheritdoc IWitness
    function rootCache(bytes32 root) external view returns (uint256, uint256, uint256) {
        RootCache memory cache = _rootCache[root];
        return (cache.treeSize, cache.timestamp, cache.height);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                     CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Emits an {OwnableRoles.OwnershipTransferred} event.
    /// @param owner The address that should be set as the initial contract owner.
    constructor(address owner) {
        _initializeOwner(owner);
        _grantRoles(owner, UPDATER_ROLE);
    }

    /*//////////////////////////////////////////////////////////////
                         READ METHODS
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IWitness
    function getCurrentTreeState() external view returns (bytes32, uint256, uint256, uint256) {
        RootCache memory cache = _rootCache[currentRoot];
        return (currentRoot, cache.treeSize, cache.timestamp, cache.height);
    }

    /// @inheritdoc IWitness
    function getCurrentTreeSize() external view returns (uint256) {
        return _rootCache[currentRoot].treeSize;
    }

    /// @inheritdoc IWitness
    function getLastUpdateTime() external view returns (uint256) {
        return _rootCache[currentRoot].timestamp;
    }

    /// @inheritdoc IWitness
    function getLastUpdateBlock() external view returns (uint256) {
        return _rootCache[currentRoot].height;
    }

    /// @inheritdoc IWitness
    function verifyProof(Proof calldata proof) external view {
        uint256 targetTreeSize = _rootCache[proof.targetRoot].treeSize;
        if (proof.index >= targetTreeSize) {
            // Provided index is out of bounds.
            revert InvalidProofLeafIdxOutOfBounds();
        }
        // leftRange covers the interval [0, index);
        // rightRange covers the interval [index + 1, targetTreeSize).
        // Verify the size of the ranges correspond to the right intervals.
        if (proof.index.popCount() != proof.leftRange.length) {
            // Provided left range does not match expected size.
            revert InvalidProofBadLeftRange();
        }
        if (getRangeSizeForNonZeroBeginningInterval(proof.index + 1, targetTreeSize) != proof.rightRange.length) {
            // Provided right range does not match expected size.
            revert InvalidProofBadRightRange();
        }
        // First merge the leaf into the left and right ranges.
        (bytes32[] calldata mergedLeft, bytes32 seed, bytes32[] calldata mergedRight) = merge(
            proof.leftRange,
            proof.leaf,
            /**
             * seedHeight=
             */
            0,
            proof.index,
            proof.rightRange,
            targetTreeSize
        );
        if (getRootForMergedRange(mergedLeft, seed, mergedRight) != proof.targetRoot) {
            // Root mismatch.
            revert InvalidProofUnrecognizedRoot();
        }
    }

    /// @inheritdoc IWitness
    function safeVerifyProof(Proof calldata proof) external view returns (bool isValid) {
        try this.verifyProof(proof) {
            isValid = true;
        } catch {
            return false;
        }
    }

    /*//////////////////////////////////////////////////////////////
                              WRITE METHODS
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IWitness
    function updateTreeRoot(
        uint256 newSize,
        bytes32[] calldata oldRange,
        bytes32[] calldata newRange
    )
        external
        onlyRoles(UPDATER_ROLE)
    {
        bytes32 _currentRoot = currentRoot;
        // ---HANDLE EMPTY TREE CASE---
        if (_currentRoot == bytes32(0)) {
            // Old range should be empty.
            if (oldRange.length != 0) {
                // Provided old range must be empty.
                revert InvalidUpdateOldRangeMismatchShouldBeEmpty();
            }
            // Verify the size of newRange corresponds to the interval [0, newTreeSize).
            if (newSize.popCount() != newRange.length) {
                // Provided new range does not match expected size.
                revert InvalidUpdateNewRangeMismatchWrongLength();
            }
            // Update the tree state.
            bytes32 root = getRoot(newRange);
            currentRoot = root;
            _rootCache[root] = RootCache(uint216(newSize), uint48(block.timestamp), uint32(block.number));
            emit RootUpdated(root, newSize);
            return;
        }
        // ---NON-EMPTY TREE CASE; VALIDATE OLD RANGE---
        // Verify oldRange corresponds to the old root.
        if (_currentRoot != getRoot(oldRange)) {
            // Provided old range does not match current root.
            revert InvalidUpdateOldRangeMismatchWrongCurrentRoot();
        }
        uint256 currentSize = _rootCache[_currentRoot].treeSize;
        // Verify size of oldRange corresponds to the size of the old root.
        if (currentSize.popCount() != oldRange.length) {
            // Provided old range does not match current tree size.
            revert InvalidUpdateOldRangeMismatchWrongLength();
        }
        // ---VALIDATE NEW RANGE---
        // New range should grow the tree.
        if (newSize <= currentSize) {
            // New tree size must be greater than current tree size.
            revert InvalidUpdateTreeSizeMustGrow();
        }
        // Verify the size of newRange corresponds to the interval [currentTreeSize, newTreeSize).
        if (getRangeSizeForNonZeroBeginningInterval(currentSize, newSize) != newRange.length) {
            // Provided new range does not match expected size.
            revert InvalidUpdateNewRangeMismatchWrongLength();
        }

        // ---HANDLE UPDATE PT 1. MERGE RANGES & CALCULATE NEW ROOT---
        // Merge oldRange with newRange to get the new combinedRange covering the new tree.
        // Merge starting with rightmost-entry in oldRange, which we call the seed.
        uint256 seedArrayIdx = oldRange.length - 1;
        bytes32 seed = oldRange[seedArrayIdx];
        // seed may start at a non-zero height.
        // Since seed's size corresponds to the value expressed by lsb(currentTreeSize),
        // we can calculate the height of seed by finding the index of the lsb.
        uint256 seedHeight = currentSize.ffs();
        // Tracker for the index of the seed node at its height as we merge the ranges.
        uint256 seedIndex = (currentSize - 1) >> seedHeight;
        (bytes32[] calldata mergedLeft, bytes32 newSeed, bytes32[] calldata mergedRight) =
            merge(oldRange[:seedArrayIdx], seed, seedHeight, seedIndex, newRange, newSize);
        bytes32 newRoot = getRootForMergedRange(mergedLeft, newSeed, mergedRight);

        // ---HANDLE UPDATE PT 2. UPDATE STATE & EMIT EVENTS---
        currentRoot = newRoot;
        _rootCache[newRoot] = RootCache(uint216(newSize), uint48(block.timestamp), uint32(block.number));
        emit RootUpdated(newRoot, newSize);
    }
}
