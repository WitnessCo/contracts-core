// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

/*//////////////////////////////////////////////////////////////
                        CUSTOM ERRORS
//////////////////////////////////////////////////////////////*/
/// Proof verification errors.
error InvalidProofLeafIdxOutOfBounds();
error InvalidProofBadLeftRange();
error InvalidProofBadRightRange();
error InvalidProofUnrecognizedRoot();

/// Tree update errors.
error InvalidUpdateOldRangeMismatchShouldBeEmpty();
error InvalidUpdateOldRangeMismatchWrongCurrentRoot();
error InvalidUpdateOldRangeMismatchWrongLength();
error InvalidUpdateTreeSizeMustGrow();
error InvalidUpdateNewRangeMismatchWrongLength();

/// @title Proof
/// @notice A proof for a given leaf in a merkle mountain range.
struct Proof {
    // The index of the leaf to be verified in the tree.
    uint256 index;
    // The leaf to be verified.
    bytes32 leaf;
    // The left range of the proof.
    bytes32[] leftRange;
    // The right range of the proof.
    bytes32[] rightRange;
    // The root of the tree the proof is being verified against.
    bytes32 targetRoot;
}

/// @title RootCache
/// @notice A packed 32 byte value containing info for any given root.
struct RootCache {
    uint176 treeSize;
    uint48 timestamp;
    uint32 height;
}

/// @title IWitness
/// @author sina.eth
/// @notice Interface for the core Witness smart contract.
/// @dev Base interface for the Witness contract.
interface IWitness {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    /// @notice Emitted when the root is updated.
    /// @param newRoot The newly accepted tree root hash.
    /// @param newSize The newly accepted tree size.
    event RootUpdated(bytes32 indexed newRoot, uint256 indexed newSize);

    /*//////////////////////////////////////////////////////////////////////////
                                   PUBLIC STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice The total amount of roots that have been checkpointed.
    function totalRoots() external view returns (uint256);

    /// @notice The current root hash.
    /// @dev This is the root hash of the most recently accepted update.
    function currentRoot() external view returns (bytes32);

    /// @notice A array containing every checkpointed root hash.
    /// @param nonce The number of total updates at the root you want to find.
    /// @return rootHash The root hash for the given update nonce.
    function roots(uint256 nonce) external view returns (bytes32);

    /// @notice A mapping of checkpointed root hashes to their corresponding tree sizes.
    /// @dev This mapping is used to keep track of the tree size corresponding to when
    /// the contract accepted a given root hash.
    /// @dev Returns 0 if the root hash is not in the mapping.
    /// @param root The root hash for the checkpoint.
    /// @return return treeSize The tree size corresponding to the root.
    /// @return timestamp The `block.timestamp` the update was made.
    /// @return block The `block.timestamp` the update was made.
    function rootCache(bytes32 root) external view returns (uint256, uint256, uint256);

    /*//////////////////////////////////////////////////////////////
                         READ METHODS
    //////////////////////////////////////////////////////////////*/

    /// @notice Helper util to get the current tree state.
    ///
    /// @return currentRoot The current root of the tree.
    /// @return treeSize The current size of the tree.
    /// @return timestamp The `block.timestamp` the update was made.
    /// @return block The `block.timestamp` the update was made.
    function getCurrentTreeState() external view returns (bytes32, uint256, uint256, uint256);

    /// @notice Helper util to get the current tree size.
    ///
    /// @return treeSize The current size of the tree.
    function getCurrentTreeSize() external view returns (uint256);

    /// @notice Helper util to get the last `block.timestamp` the tree was updated.
    ///
    /// @return timestamp The `block.timestamp` the update was made.
    function getLastUpdateTime() external view returns (uint256);

    /// @notice Helper util to get the last `block.number` the tree was updated.
    ///
    /// @return block The `block.timestamp` the update was made.
    function getLastUpdateBlock() external view returns (uint256);

    /// @notice Verifies a proof for a given leaf. Throws an error if the proof is invalid.
    ///
    /// @dev Notes:
    /// - For invalid proofs, this method will throw with an error indicating why the proof failed to validate.
    /// - The proof must validate against a checkpoint the contract has previously accepted.
    ///
    /// @param proof The proof to be verified.
    function verifyProof(Proof calldata proof) external view;

    /// @notice Verifies a proof for a given leaf, returning a boolean instead of throwing for invalid proofs.
    ///
    /// @dev This method is a wrapper around `verifyProof` that catches any errors and returns false instead.
    ///      The params and logic are otherwise the same as `verifyProof`.
    ///
    /// @param proof The proof to be verified.
    function safeVerifyProof(Proof calldata proof) external view returns (bool isValid);

    /*//////////////////////////////////////////////////////////////
                              WRITE METHODS
    //////////////////////////////////////////////////////////////*/

    /// @notice Updates the tree root to a larger tree.
    ///
    /// @dev Emits a {RootUpdated} event.
    ///
    /// Notes:
    /// - A range proof is verified to ensure the new root is consistent with the previous root.
    /// - Roots are stored in storage for easier retrieval in the future, along with the treeSize
    ///   they correspond to.
    ///
    /// Requirements:
    /// - `msg.sender` must be the contract owner.
    /// - `newSize` must be greater than the current tree size.
    /// - `oldRange` must correspond to the current tree root and size.
    /// - size check must pass on `newRange`.
    ///
    /// After these checks are verified, the new root is calculated based on `oldRange` and `newRange`.
    ///
    /// @param newSize The size of the updated tree.
    /// @param oldRange A compact range representing the current root.
    /// @param newRange A compact range representing the diff between oldRange and the new root's coverage.
    function updateTreeRoot(uint256 newSize, bytes32[] calldata oldRange, bytes32[] calldata newRange) external;
}
