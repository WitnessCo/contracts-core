// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ECDSA} from "solady/utils/ECDSA.sol";
import {ERC721} from "solady/tokens/ERC721.sol";

import {IWitness} from "./IWitness.sol";
import {IERC721P} from "./IERC721P.sol";

error WitnessSimpleOpenEdition__OwnerAlreadyMinted();

/// @title WitnessSimpleOpenEdition
/// @notice A simple ERC721 implementation that uses Witness for provenance.
///         This contract is a very simple open edition implementation of an ERC721P.
///         It allows anyone to mint a token, as long as they sign over the
///         baseTokenURI's digest and illustrates its inclusion in Witness.
///         The sole constraint is that each address can only mint one token.
contract WitnessSimpleOpenEdition is ERC721, IERC721P {
    using ECDSA for bytes;
    using ECDSA for bytes32;

    /*//////////////////////////////////////////////////////////////////////////
                                   PRIVATE STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev The name of the token collection.
    string private __name;

    /// @dev The symbol of the token collection.
    string private __symbol;

    /// @dev The URI for the contract metadata.
    string private __contractURI;

    /*//////////////////////////////////////////////////////////////////////////
                                    PUBLIC STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev The base tokenURI for the token collection.
    string public baseTokenURI;

    /// @dev The hash of the baseTokenURI. Used as the digestHash that
    ///      a user signs over to mint.
    bytes32 public immutable contentURIHash;

    /// @dev A mapping of addresses to whether they have minted a token.
    mapping(address => bool) public minted;

    /*//////////////////////////////////////////////////////////////////////////
                                     CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Initializer for the contract.
    /// @param _witness The address that's used as the Witness to verify provenance against.
    /// @param _name The name of the token collection.
    /// @param _symbol The symbol of the token collection.
    /// @param _contractURI The URI for the contract metadata.
    /// @param _basetokenURI The base URI for the token metadata.
    constructor(
        IWitness _witness,
        string memory _name,
        string memory _symbol,
        string memory _contractURI,
        string memory _basetokenURI
    ) IERC721P(_witness) {
        __name = _name;
        __symbol = _symbol;
        __contractURI = _contractURI;
        baseTokenURI = _basetokenURI;
        contentURIHash = bytes(_basetokenURI).toEthSignedMessageHash();
    }

    /*//////////////////////////////////////////////////////////////
                READ METHODS - ERC721 OVERRIDES
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc ERC721
    function name() public view override returns (string memory) {
        return __name;
    }

    /// @inheritdoc ERC721
    function symbol() public view override returns (string memory) {
        return __symbol;
    }

    /// @inheritdoc ERC721
    function tokenURI(uint256) public view override returns (string memory) {
        return baseTokenURI;
    }

    /// @dev Returns the contract metadata URI.
    function contractURI() public view returns (string memory) {
        return __contractURI;
    }

    /*//////////////////////////////////////////////////////////////
                READ METHODS - IERC721P OVERRIDES
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IERC721P
    function bridgedTokenURI(bytes calldata) public view override returns (string memory) {
        return baseTokenURI;
    }

    /// @inheritdoc IERC721P
    function getBridgedOwner(bytes calldata signature) public view override returns (address owner) {
        owner = contentURIHash.recover(signature);
    }

    /// @inheritdoc IERC721P
    function bridge(
        bytes calldata signature, // bridgeData
        uint256 leafIndex,
        bytes32[] calldata leftProof,
        bytes32[] calldata rightProof,
        bytes32 targetRoot
    ) public override {
        // Only EOAs for now.
        address owner = contentURIHash.recover(signature);
        // Check that the owner hasn't already minted.
        if (minted[owner]) {
            revert WitnessSimpleOpenEdition__OwnerAlreadyMinted();
        }
        // Mark the owner as having minted.
        minted[owner] = true;
        // Verify proof for that leaf/ID.
        // This call will throw an error if the proof is invalid!
        verifyProof(leafIndex, getProvenanceHash(signature), leftProof, rightProof, targetRoot);
        // All check passed; "bridge" the token to this chain by minting it to this contract.
        // _safeMint reverts if the token already exists.
        // Note: using leafIndex as the tokenID.
        _safeMint(owner, leafIndex);
    }

    /*//////////////////////////////////////////////////////////////
                            UTIL METHODS
    //////////////////////////////////////////////////////////////*/

    /// @dev Returns the owner of the token, without throwing.
    function safeOwnerOf(uint256 id) public view returns (address owner) {
        // Solady's native ownerOf function throws if the token doesn't exist.
        // Frontend doesn't like this.
        if (!_exists(id)) {
            return address(0);
        }
        return ownerOf(id);
    }
}
