// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { LibBit } from "solady/utils/LibBit.sol";

/// @notice Helper for calculating range size for a non-zero-starting interval.
/// @dev The bitmath here decomposes the interval into two parts that in
///      combination represent the compact range needed to express the interval.
/// @param begin The start of the interval of the range's coverage (inclusive).
/// @param end The end of the interval of the range's coverage (exclusive).
/// @return left Bitmap representing the left part of the interval.
/// @return right Bitmap representing the right part of the interval.
function decomposeNonZeroInterval(uint256 begin, uint256 end) pure returns (uint256 left, uint256 right) {
    // Since `begin` represents the start of the interval, the index before that represents the
    // index of the last node included in the complimentary "zero-index-starting" interval.
    // Abbreviation of `complimentaryIntervalEndIdxInclusive`.
    uint256 complIntervalEndIdxInclusive = begin - 1;
    // End represents the index of the first node that's not included in the interval.
    // Recall that the bit representations of node indices represent their merge path.
    // The differences in merge path between the complimentary interval and the beginning
    // of the next interval is used to determine the max height of the left or right
    // components of the desired interval via its highest-significance set interval.
    uint256 divergeHeight = LibBit.fls(complIntervalEndIdxInclusive ^ end);
    // heightMask consists of `diverge` 1s, used to cap the heights of the left and right
    // components of the desired interval.
    // For example, if `diverge=3`, then `heightMask=0b111`.
    uint256 heightMask = (1 << divergeHeight) - 1;
    // The left portion of the interval consists of all nodes that will be merged into the
    // complementary interval, capped by `heightMask`. ~complIntervalEndIdxInclusive lets us select
    // the right-merges of the merge path.
    left = (~complIntervalEndIdxInclusive) & heightMask;
    // The right portion of the interval can be represented by all right-merges of `end`, capped
    // by `heightMask`. Recall that `end` represents the first node that's not included in the interval,
    // so its right merges correspond to nodes in the interval.
    right = end & heightMask;
}

/// @notice Returns the expected size of a compact range needed to express a non-zero-starting interval.
/// @param start The start of the interval of the range's coverage (inclusive).
/// @param end The end of the interval of the range's coverage (exclusive).
/// @return size The size of the compact range needed to express the interval [start, end).
function getRangeSizeForNonZeroBeginningInterval(uint256 start, uint256 end) pure returns (uint256) {
    if (start == end) {
        return 0;
    }
    (uint256 left, uint256 right) = decomposeNonZeroInterval(start, end);
    return LibBit.popCount(left) + LibBit.popCount(right);
}

/// @notice Returns the root for a given compact range.
/// @dev This method "bags the peaks" of the compact range, folding in from R2L.
/// @param hashes The hashes of the compact range to calculate the root for.
/// @return root The root of the compact range.
function getRoot(bytes32[] calldata hashes) pure returns (bytes32 root) {
    uint256 i = hashes.length;
    // i is never 0, so don't need the following condition.
    // if (i == 0) return keccak256("");
    root = hashes[--i];
    while (i > 0) {
        root = hashToParent(hashes[--i], root);
    }
}

/// @notice Utility for calculating the root of a compact range provided in a gas-convenient representation.
/// @param leftRange The left portion of the compact range to merge.
/// @param seed The middle portion of the compact range to merge.
/// @param rightRange The right portion of the compact range to merge.
/// @return root The calculated root of the compact range.
function getRootForMergedRange(
    bytes32[] calldata leftRange,
    bytes32 seed,
    bytes32[] calldata rightRange
)
    pure
    returns (bytes32 root)
{
    // Total merged range is comprised of the following arrays concattenated:
    // - leftRange + seed + rightRange
    // Merklizing a compact range involves "rolling it up" from R2L.
    if (rightRange.length == 0) {
        root = seed;
    } else {
        root = rightRange[rightRange.length - 1];
        for (uint256 i = rightRange.length - 1; i > 0; --i) {
            root = hashToParent(rightRange[i - 1], root);
        }
        root = hashToParent(seed, root);
    }
    for (uint256 i = leftRange.length; i > 0; --i) {
        root = hashToParent(leftRange[i - 1], root);
    }
}

/// @notice Hashes two bytes32s together as into a merkle parent.
/// @param left The left child to hash.
/// @param right The right child to hash.
/// @return parent The parent hash.
function hashToParent(bytes32 left, bytes32 right) pure returns (bytes32 parent) {
    parent = keccak256(abi.encodePacked(left, right));
}

/// @notice Merges two compact ranges along a given seed node.
///
/// @dev Merge folds hashes in from leftRange and rightRange into
///      seed in order to create a combined compact range.
///
///      The merged range is left + seed + right.
///
///      leftRange is assumed to start its coverage at index 0.
///
/// @param leftRange The left compact range to merge.
/// @param seed The seed node to merge along.
/// @param seedHeight The height of the seed node.
/// @param seedIndex The index of the seed node.
/// @param rightRange The right compact range to merge.
/// @param rightRangeEnd The end of the right range's coverage.
/// @return left The left portion of the merged compact range.
/// @return newSeed The new seed node of the merged range.
/// @return right The right portion of the merged compact range.
function merge(
    bytes32[] calldata leftRange,
    bytes32 seed,
    uint256 seedHeight,
    uint256 seedIndex,
    bytes32[] calldata rightRange,
    uint256 rightRangeEnd
)
    pure
    returns (bytes32[] calldata left, bytes32 newSeed, bytes32[] calldata right)
{
    uint256 leftCursor = leftRange.length;
    uint256 rightCursor = 0;
    uint256 seedRangeStart = seedIndex * (1 << seedHeight);
    for (; seedHeight < 255; ++seedHeight) {
        uint256 layerCoverage = 1 << seedHeight;
        if (seedIndex & 1 == 0) {
            // Right merge, or break if not possible.
            uint256 mergedRangeEnd = seedRangeStart + (2 * layerCoverage);
            if (mergedRangeEnd > rightRangeEnd) {
                break;
            }
            seed = hashToParent(seed, rightRange[rightCursor++]);
        } else {
            // Left merge, or break if not possible.
            if (layerCoverage > seedRangeStart) {
                break;
            }
            seedRangeStart -= layerCoverage;
            seed = hashToParent(leftRange[--leftCursor], seed);
        }
        seedIndex >>= 1;
    }
    newSeed = seed;
    left = leftRange[:leftCursor];
    right = rightRange[rightCursor:];
}
