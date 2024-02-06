// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.18;

import { PRBTest } from "@prb/test/src/PRBTest.sol";
import { StdUtils } from "forge-std/src/StdUtils.sol";
import { LibBit } from "solady/utils/LibBit.sol";

import { Proof } from "src/interfaces/IWitness.sol";
import { Witness } from "src/Witness.sol";
import { getRoot, hashToParent, decomposeNonZeroInterval } from "src/WitnessUtils.sol";

contract WitnessTest is PRBTest, StdUtils {
    Witness public c;
    uint256[] public levels;
    uint256[] public indexes;
    bytes32[] public oldRange;
    bytes32[] public newRange;

    function setUp() public {
        c = new Witness(address(this));
    }

    function testEmptyToSizeOne() public {
        uint256 _size = c.rootCache(c.currentRoot());
        assertEq(_size, 0);
        newRange = new bytes32[](1);
        newRange[0] = bytes32(uint256(1));
        c.updateTreeRoot(1, new bytes32[](0), newRange);
        (bytes32 root, uint256 size) = c.getCurrentTreeState();
        assertEq(size, 1);
        assertEq(root, bytes32(uint256(1)));
    }

    function testEmptyToSizeTwo() public {
        uint256 _size = c.rootCache(c.currentRoot());
        assertEq(_size, 0);
        bytes32[] memory rangeOne = new bytes32[](1);
        rangeOne[0] = bytes32(uint256(1));
        c.updateTreeRoot(1, new bytes32[](0), rangeOne);
        (, uint256 size) = c.getCurrentTreeState();
        assertEq(size, 1);
        bytes32[] memory rangeTwo = new bytes32[](1);
        rangeTwo[0] = bytes32(uint256(2));
        c.updateTreeRoot(2, rangeOne, rangeTwo);
        (, size) = c.getCurrentTreeState();
        assertEq(size, 2);
    }

    function testManuallysafeVerifyProofsForSizeTen() public {
        // Let's start by making a tree of size 3 and
        // verifying it, as a sanity check.
        bytes32[] memory range = new bytes32[](2);
        range[0] = getInnerNode(1, 0);
        range[1] = getLeaf(2);
        c.updateTreeRoot(3, new bytes32[](0), range);
        (bytes32 currentRoot,) = c.getCurrentTreeState();
        assertEq(currentRoot, hashToParent(range[0], range[1]));

        // Verify proof for the leaf at each index, 0 through 2.
        // leaf(0)
        uint256 leafIdx = 0;
        bytes32[] memory leftProof = new bytes32[](0);
        bytes32[] memory rightProof = new bytes32[](2);
        rightProof[0] = getLeaf(1);
        rightProof[1] = getLeaf(2);
        Proof memory proof = Proof(leafIdx++, getLeaf(0), leftProof, rightProof, c.currentRoot());
        assertTrue(c.safeVerifyProof(proof));

        // leaf1
        leftProof = new bytes32[](1);
        leftProof[0] = getLeaf(0);
        rightProof = new bytes32[](1);
        rightProof[0] = getLeaf(2);
        assertTrue(c.safeVerifyProof(Proof(leafIdx++, getLeaf(1), leftProof, rightProof, c.currentRoot())));

        // leaf2
        leftProof = new bytes32[](1);
        leftProof[0] = range[0];
        rightProof = new bytes32[](0);
        assertTrue(c.safeVerifyProof(Proof(leafIdx++, getLeaf(2), leftProof, rightProof, c.currentRoot())));

        // Now update the tree to size 10 and re-test proofs.
        // Set up the old and new range, for updating the tree.
        oldRange = range;
        newRange = new bytes32[](3);
        newRange[0] = getLeaf(3);
        newRange[1] = getInnerNode(2, 1);
        newRange[2] = getInnerNode(1, 4);
        // Update the tree root.
        c.updateTreeRoot(10, oldRange, newRange);
        // Verify the root.
        bytes32 expectedRoot = hashToParent(getInnerNode(3, 0), getInnerNode(1, 4));
        (currentRoot,) = c.getCurrentTreeState();
        assertEq(currentRoot, expectedRoot);

        // Verify proof for the leaf at each index, 0 through 9.
        // leaf0
        leafIdx = 0;
        leftProof = new bytes32[](0);
        rightProof = new bytes32[](4);
        rightProof[0] = getLeaf(1);
        rightProof[1] = getInnerNode(1, 1);
        rightProof[2] = getInnerNode(2, 1);
        rightProof[3] = getInnerNode(1, 4);
        assertTrue(c.safeVerifyProof(Proof(leafIdx++, getLeaf(0), leftProof, rightProof, c.currentRoot())));

        // leaf1
        leftProof = new bytes32[](1);
        leftProof[0] = getLeaf(0);
        rightProof = new bytes32[](3);
        rightProof[0] = getInnerNode(1, 1);
        rightProof[1] = getInnerNode(2, 1);
        rightProof[2] = getInnerNode(1, 4);
        assertTrue(c.safeVerifyProof(Proof(leafIdx++, getLeaf(1), leftProof, rightProof, c.currentRoot())));

        // leaf2
        leftProof = new bytes32[](1);
        leftProof[0] = getInnerNode(1, 0);
        rightProof = new bytes32[](3);
        rightProof[0] = getLeaf(3);
        rightProof[1] = getInnerNode(2, 1);
        rightProof[2] = getInnerNode(1, 4);
        assertTrue(c.safeVerifyProof(Proof(leafIdx++, getLeaf(2), leftProof, rightProof, c.currentRoot())));

        // leaf3
        leftProof = new bytes32[](2);
        leftProof[0] = getInnerNode(1, 0);
        leftProof[1] = getLeaf(2);
        rightProof = new bytes32[](2);
        rightProof[0] = getInnerNode(2, 1);
        rightProof[1] = getInnerNode(1, 4);
        assertTrue(c.safeVerifyProof(Proof(leafIdx++, getLeaf(3), leftProof, rightProof, c.currentRoot())));

        // leaf4
        leftProof = new bytes32[](1);
        leftProof[0] = getInnerNode(2, 0);
        rightProof = new bytes32[](3);
        rightProof[0] = getLeaf(5);
        rightProof[1] = getInnerNode(1, 3);
        rightProof[2] = getInnerNode(1, 4);
        assertTrue(c.safeVerifyProof(Proof(leafIdx++, getLeaf(4), leftProof, rightProof, c.currentRoot())));

        // leaf5
        leftProof = new bytes32[](2);
        leftProof[0] = getInnerNode(2, 0);
        leftProof[1] = getLeaf(4);
        rightProof = new bytes32[](2);
        rightProof[0] = getInnerNode(1, 3);
        rightProof[1] = getInnerNode(1, 4);
        assertTrue(c.safeVerifyProof(Proof(leafIdx++, getLeaf(5), leftProof, rightProof, c.currentRoot())));

        // leaf6
        leftProof = new bytes32[](2);
        leftProof[0] = getInnerNode(2, 0);
        leftProof[1] = getInnerNode(1, 2);
        rightProof = new bytes32[](2);
        rightProof[0] = getLeaf(7);
        rightProof[1] = getInnerNode(1, 4);
        assertTrue(c.safeVerifyProof(Proof(leafIdx++, getLeaf(6), leftProof, rightProof, c.currentRoot())));

        // leaf7
        leftProof = new bytes32[](3);
        leftProof[0] = getInnerNode(2, 0);
        leftProof[1] = getInnerNode(1, 2);
        leftProof[2] = getLeaf(6);
        rightProof = new bytes32[](1);
        rightProof[0] = getInnerNode(1, 4);
        assertTrue(c.safeVerifyProof(Proof(leafIdx++, getLeaf(7), leftProof, rightProof, c.currentRoot())));

        // leaf8
        leftProof = new bytes32[](1);
        leftProof[0] = getInnerNode(3, 0);
        rightProof = new bytes32[](1);
        rightProof[0] = getLeaf(9);
        assertTrue(c.safeVerifyProof(Proof(leafIdx++, getLeaf(8), leftProof, rightProof, c.currentRoot())));

        // leaf9
        leftProof = new bytes32[](2);
        leftProof[0] = getInnerNode(3, 0);
        leftProof[1] = getLeaf(8);
        rightProof = new bytes32[](0);
        assertTrue(c.safeVerifyProof(Proof(leafIdx++, getLeaf(9), leftProof, rightProof, c.currentRoot())));

        // Now try updating the tree to size 12, for fun.
        oldRange = new bytes32[](2);
        oldRange[0] = getInnerNode(3, 0);
        oldRange[1] = getInnerNode(1, 4);
        newRange = new bytes32[](1);
        newRange[0] = getInnerNode(1, 5);
        // Update the tree root.
        c.updateTreeRoot(12, oldRange, newRange);
        // Verify the root.
        expectedRoot = hashToParent(getInnerNode(3, 0), getInnerNode(2, 2));
        (currentRoot,) = c.getCurrentTreeState();
        assertEq(currentRoot, expectedRoot);

        // Now try updating the tree to size 13, for fun.
        oldRange = new bytes32[](2);
        oldRange[0] = getInnerNode(3, 0);
        oldRange[1] = getInnerNode(2, 2);
        newRange = new bytes32[](1);
        newRange[0] = getLeaf(12);
        // Update the tree root.
        c.updateTreeRoot(13, oldRange, newRange);
        // Verify the root.
        expectedRoot = hashToParent(getInnerNode(3, 0), hashToParent(getInnerNode(2, 2), getLeaf(12)));
        (currentRoot,) = c.getCurrentTreeState();
        assertEq(currentRoot, expectedRoot);

        // Now try updating the tree to size 14, for fun.
        oldRange = new bytes32[](3);
        oldRange[0] = getInnerNode(3, 0);
        oldRange[1] = getInnerNode(2, 2);
        oldRange[2] = getLeaf(12);
        newRange = new bytes32[](1);
        newRange[0] = getLeaf(13);
        // Update the tree root.
        c.updateTreeRoot(14, oldRange, newRange);
        // Verify the root.
        expectedRoot = hashToParent(getInnerNode(3, 0), hashToParent(getInnerNode(2, 2), getInnerNode(1, 6)));
        (currentRoot,) = c.getCurrentTreeState();
        assertEq(currentRoot, expectedRoot);

        // Now try updating the tree to size 15, for fun.
        oldRange = new bytes32[](3);
        oldRange[0] = getInnerNode(3, 0);
        oldRange[1] = getInnerNode(2, 2);
        oldRange[2] = getInnerNode(1, 6);
        newRange = new bytes32[](1);
        newRange[0] = getLeaf(14);
        // Update the tree root.
        c.updateTreeRoot(15, oldRange, newRange);
        // Verify the root.
        expectedRoot = hashToParent(
            getInnerNode(3, 0), hashToParent(getInnerNode(2, 2), hashToParent(getInnerNode(1, 6), getLeaf(14)))
        );
        (currentRoot,) = c.getCurrentTreeState();
        assertEq(currentRoot, expectedRoot);
    }

    function testFuzzedTreeUpdate(uint256 firstUpdate, uint256 secondUpdate, uint256 thirdUpdate) public {
        uint256 upperBound = 2 ** 10; // = 1024
        firstUpdate = bound(firstUpdate, 2, upperBound);
        secondUpdate = bound(secondUpdate, 1, upperBound);
        thirdUpdate = bound(thirdUpdate, 1, upperBound);
        // Set up the oldRange, for initially setting the tree.
        getRangeNodeIds(0, firstUpdate);
        getOldRange();
        c.updateTreeRoot(firstUpdate, new bytes32[](0), oldRange);
        // Verify the root.
        assertEq(this._getRoot(oldRange), c.currentRoot());

        // Set up the newRange, for updating the tree.
        uint256 updatedTreeSize = firstUpdate + secondUpdate;
        getRangeNodeIds(firstUpdate, updatedTreeSize);
        getNewRange();
        // Update the tree root.
        c.updateTreeRoot(updatedTreeSize, oldRange, newRange);
        // Verify the root.
        getRangeNodeIds(0, updatedTreeSize);
        getOldRange();
        assertEq(this._getRoot(oldRange), c.currentRoot());

        // Set up the newRange for the third update.
        updatedTreeSize += thirdUpdate;
        getRangeNodeIds(updatedTreeSize - thirdUpdate, updatedTreeSize);
        getNewRange();
        // Update the tree root.
        c.updateTreeRoot(updatedTreeSize, oldRange, newRange);
        // Verify the root.
        getRangeNodeIds(0, updatedTreeSize);
        getOldRange();
        assertEq(this._getRoot(oldRange), c.currentRoot());
    }

    function _getRoot(bytes32[] calldata hashes) public pure returns (bytes32 root) {
        return getRoot(hashes);
    }

    function getNewRange() internal {
        delete newRange;
        for (uint256 i = 0; i < levels.length; ++i) {
            newRange.push(getInnerNode(levels[i], indexes[i]));
        }
    }

    function getOldRange() internal {
        delete oldRange;
        for (uint256 i = 0; i < levels.length; ++i) {
            oldRange.push(getInnerNode(levels[i], indexes[i]));
        }
    }

    // Naive/gas-inefficient implementation, for testing purposes.
    function getRangeNodeIds(uint256 begin, uint256 end) internal {
        delete levels;
        delete indexes;
        uint256 left;
        uint256 right = end;
        if (begin != 0) {
            (left, right) = decomposeNonZeroInterval(begin, end);
        }
        // Track the coverage to know which index to use based on height.
        uint256 pos = begin;
        // Iterate over subtrees along the left border of the range from LTR.
        // LTR here means from lower bits to higher bits, where 1-bits represent
        // range nodes.
        while (left != 0) {
            // The index counting from the least significant bit represents the
            // height of the node.
            uint256 level = LibBit.ffs(left);
            // From the rightmost-covered node, we can find the index for the
            levels.push(level);
            // rangenode by offsetting for the current height.
            indexes.push(pos >> level);
            // Clear the bit and increment pos to move on to the next subtree.
            uint256 bit = 1 << level;
            left ^= bit;
            pos += bit;
        }
        // Ditto for right border of the range. Note that we iterate from RTL,
        // going from the most-significant bit to the least-significant bit.
        // This represents ordering from the largest subtrees to the smallest.
        while (right != 0) {
            uint256 level = LibBit.fls(right);
            levels.push(level);
            indexes.push(pos >> level);
            uint256 bit = 1 << level;
            right ^= bit;
            pos += bit;
        }
    }
}

function getLeaf(uint256 index) pure returns (bytes32) {
    // For testing purposes, a leaf's hash is its index.
    return bytes32(uint256(index));
}

function getInnerNode(uint256 level, uint256 index) pure returns (bytes32) {
    if (level == 0) {
        return getLeaf(index);
    }
    // Recursively derive the inner node.
    bytes32 leftChild = getInnerNode(level - 1, index * 2);
    bytes32 rightChild = getInnerNode(level - 1, index * 2 + 1);
    return hashToParent(leftChild, rightChild);
}
