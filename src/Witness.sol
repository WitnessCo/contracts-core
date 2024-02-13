// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { OwnableRoles } from "solady/auth/OwnableRoles.sol";
import { LibBit } from "solady/utils/LibBit.sol";
import { LibZip } from "solady/utils/LibZip.sol";
import { SafeCastLib } from "solady/utils/SafeCastLib.sol";

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
    RootInfo
} from "./interfaces/IWitness.sol";
import {
    getRangeSizeForNonZeroBeginningInterval,
    getRoot,
    getRootForMergedRange,
    merge,
    ProofError,
    validateProof
} from "./WitnessUtils.sol";

/// @title Witness
/// @author sina.eth
/// @custom:coauthor runtheblocks.eth
/// @notice The core Witness smart contract.
/// @dev The Witness smart contract tracks a merkle mountain range and enforces
///      that any newly posted merkle root is consistent with the previous root.
contract Witness is IWitness, OwnableRoles {
    using SafeCastLib for uint256;
    using LibBit for uint256;

    /*//////////////////////////////////////////////////////////////////////////
                                   CONSTANTS
    //////////////////////////////////////////////////////////////////////////*/

    uint256 public constant UPDATER_ROLE = _ROLE_0;

    /*//////////////////////////////////////////////////////////////////////////
                                MUTABLE STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IWitness
    bytes32 public currentRoot;

    mapping(bytes32 root => RootInfo cache) internal _rootInfo;

    /// @inheritdoc IWitness
    function rootInfo(bytes32 root) public view virtual returns (RootInfo memory) {
        return _rootInfo[root];
    }

    /// @inheritdoc IWitness
    function rootCache(bytes32 root) public view virtual returns (uint256) {
        return _rootInfo[root].treeSize;
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
    function getCurrentTreeState() external view virtual returns (bytes32, uint256) {
        bytes32 _currentRoot = currentRoot;
        return (_currentRoot, _rootInfo[_currentRoot].treeSize);
    }

    /// @inheritdoc IWitness
    function getLastUpdateTime() external view virtual returns (uint256) {
        return _rootInfo[currentRoot].timestamp;
    }

    /// @inheritdoc IWitness
    function getLastUpdateBlock() external view virtual returns (uint256) {
        return _rootInfo[currentRoot].height;
    }

    /// @inheritdoc IWitness
    function verifyProof(Proof calldata proof) external view virtual {
        ProofError e = validateProof(proof, _rootInfo[proof.targetRoot].treeSize);
        if (e == ProofError.NONE) {
            return;
        }

        if (e == ProofError.InvalidProofLeafIdxOutOfBounds) {
            revert InvalidProofLeafIdxOutOfBounds();
        }

        if (e == ProofError.InvalidProofBadLeftRange) {
            revert InvalidProofBadLeftRange();
        }

        if (e == ProofError.InvalidProofBadRightRange) {
            revert InvalidProofBadRightRange();
        }

        if (e == ProofError.InvalidProofUnrecognizedRoot) {
            revert InvalidProofUnrecognizedRoot();
        }
    }

    /// @inheritdoc IWitness
    function safeVerifyProof(Proof calldata proof) external view returns (bool isValid) {
        return validateProof(proof, _rootInfo[proof.targetRoot].treeSize) == ProofError.NONE;
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
        virtual
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
            _rootInfo[root] = RootInfo(newSize.toUint176(), block.timestamp.toUint40(), block.number.toUint40());
            emit RootUpdated(root, newSize);
            return;
        }
        // ---NON-EMPTY TREE CASE; VALIDATE OLD RANGE---
        // Verify oldRange corresponds to the old root.
        if (_currentRoot != getRoot(oldRange)) {
            // Provided old range does not match current root.
            revert InvalidUpdateOldRangeMismatchWrongCurrentRoot();
        }
        uint256 currentSize = _rootInfo[_currentRoot].treeSize;
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
        _rootInfo[newRoot] = RootInfo(newSize.toUint176(), block.timestamp.toUint40(), block.number.toUint40());
        emit RootUpdated(newRoot, newSize);
    }

    /*//////////////////////////////////////////////////////////////
                        L2 CALLDATA OPTIMIZATION
    //////////////////////////////////////////////////////////////*/

    /// @dev For efficiency, this function will directly return the results, terminating
    ///      the context. If called internally, it must be called at the end of the function.
    fallback() external virtual {
        LibZip.cdFallback();
    }
}
