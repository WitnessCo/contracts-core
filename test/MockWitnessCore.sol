// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import { Initializable } from "solady/src/utils/Initializable.sol";
import { OwnableRoles } from "solady/src/auth/OwnableRoles.sol";
import { LibBit } from "solady/src/utils/LibBit.sol";
import { LibZip } from "solady/src/utils/LibZip.sol";
import { SafeCastLib } from "solady/src/utils/SafeCastLib.sol";

import { IWitness, Proof, RootInfo } from "../src/interfaces/IWitness.sol";
import {
    getRangeSizeForNonZeroBeginningInterval,
    getRoot,
    getRootForMergedRange,
    merge,
    ProofError,
    validateProof
} from "../src/WitnessUtils.sol";

contract MockWitnessCore is Initializable, OwnableRoles {
	using SafeCastLib for uint256;
    using LibBit for uint256;
	uint256 public constant UPDATER_ROLE = _ROLE_1;
	bytes32 public currentRoot;
	mapping(bytes32 root => RootInfo cache) internal _rootInfo;

	function initialize(address _owner, uint256 _size, bytes32[] calldata _range) external initializer {
		_initializeOwner(_owner);
		_grantRoles(_owner, UPDATER_ROLE);
		_initializeTreeRoot(_size, _range);
	}

	function updateTreeRoot(
		uint256 newSize,
		bytes32[] calldata oldRange,
		bytes32[] calldata newRange
	) external virtual onlyRoles(UPDATER_ROLE) {
        bytes32 _currentRoot = currentRoot;
        // ---NON-EMPTY TREE CASE; VALIDATE OLD RANGE---
        // Verify oldRange corresponds to the old root.
        if (_currentRoot != getRoot(oldRange)) {
            // Provided old range does not match current root.
            revert IWitness.InvalidUpdateOldRangeMismatchWrongCurrentRoot();
        }
        uint256 currentSize = _rootInfo[_currentRoot].treeSize;
        // Verify size of oldRange corresponds to the size of the old root.
        if (currentSize.popCount() != oldRange.length) {
            // Provided old range does not match current tree size.
            revert IWitness.InvalidUpdateOldRangeMismatchWrongLength();
        }
        // ---VALIDATE NEW RANGE---
        // New range should grow the tree.
        if (newSize <= currentSize) {
            // New tree size must be greater than current tree size.
            revert IWitness.InvalidUpdateTreeSizeMustGrow();
        }
        // Verify the size of newRange corresponds to the interval [currentTreeSize, newTreeSize).
        if (getRangeSizeForNonZeroBeginningInterval(currentSize, newSize) != newRange.length) {
            // Provided new range does not match expected size.
            revert IWitness.InvalidUpdateNewRangeMismatchWrongLength();
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
        // emit RootUpdated(newRoot, newSize);
	}

	function _initializeTreeRoot(
		uint256 _size,
		bytes32[] calldata _range
	) internal {
        bytes32 _currentRoot = currentRoot;
        // ---HANDLE EMPTY TREE CASE---
        if (_currentRoot == bytes32(0)) {
            if (_size.popCount() != _range.length) {
                revert IWitness.InvalidUpdateNewRangeMismatchWrongLength();
            }
            bytes32 root = getRoot(_range);
            currentRoot = root;
            _rootInfo[root] = RootInfo(_size.toUint176(), block.timestamp.toUint40(), block.number.toUint40());
            // emit RootUpdated(root, _size);
            return;
        }
	}
}
