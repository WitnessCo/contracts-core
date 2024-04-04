// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import { LibClone } from "solady/src/utils/LibClone.sol";
import { OwnableRoles } from "solady/src/auth/OwnableRoles.sol";

import { IWitnessFactory } from "src/interfaces/IWitnessFactory.sol";
import { MockWitnessCore } from "test/MockWitnessCore.sol";

/// @title WitnessFactory
/// @author swa.eth
/// @notice The Witness Factory smart contract.
/// @dev The Witness Factory smart contract creates new instances of the core Witness 
/// 	 smart contract with custom auth control and also serves as a contract registry.
contract WitnessFactory is IWitnessFactory, OwnableRoles {
  	/*//////////////////////////////////////////////////////////////////////////
                                   CONSTANTS
    //////////////////////////////////////////////////////////////////////////*/

  	/// @inheritdoc IWitnessFactory
	uint256 public constant ADMIN_ROLE = _ROLE_0;

	/*//////////////////////////////////////////////////////////////////////////
                                MUTABLE STORAGE
    //////////////////////////////////////////////////////////////////////////*/
	
	/// @inheritdoc IWitnessFactory
	address public implementation;
	
	/// @inheritdoc IWitnessFactory
	uint96 public instanceId;
	
	/// @inheritdoc IWitnessFactory
	mapping(uint96 => address) public instances;
	
	/// @dev Mapping of deployer address to incremental nonce value used for generating salts.
	mapping(address => uint256) internal _nonces;

	/*//////////////////////////////////////////////////////////////////////////
								CONSTRUCTOR
	//////////////////////////////////////////////////////////////////////////*/

  	/// @dev Emits an {OwnableRoles.OwnershipTransferred} event.
	/// @param _owner The address that should be set as the initial contract owner.
	/// @param _implementation The address that should be set as the initial core contract.
	constructor(address _owner, address _implementation) {
		_initializeOwner(_owner);
		_grantRoles(_owner, ADMIN_ROLE);
		_setImplementation(_implementation);
	}

	/*//////////////////////////////////////////////////////////////
                              WRITE METHODS
    //////////////////////////////////////////////////////////////*/

  	/// @inheritdoc IWitnessFactory
	function createWitness(address _owner, uint256 _size, bytes32[] calldata _range) external returns (address instance) {
		// Revert when owner is zero address.
		if (_owner == address(0)) { 
			revert InvalidOwnerZeroAddress();
		}
		
		// Generate salt using deployer address and current nonce.
		bytes32 salt = keccak256(abi.encode(msg.sender, _nonces[msg.sender]));
		
		// Create new deterministic clone contract using current implementation and generated salt.
		instance = LibClone.cloneDeterministic(implementation, salt);
		
		// Increment deployer nonce.
		_nonces[msg.sender]++;
		
		// Set mapping of instance ID to address of newly created instance.
		instances[++instanceId] = instance;
		
		// Emit event for creating new core contract.
		emit WitnessCreated(instanceId, instance, _owner);
		
		// Initialize new core Witness contract.
		MockWitnessCore(instance).initialize(_owner, _size, _range);
	}

  	/// @inheritdoc IWitnessFactory
	function setImplementation(address _implementation) external onlyRoles(ADMIN_ROLE) {
		_setImplementation(_implementation);
	}

	/*//////////////////////////////////////////////////////////////
                         	READ METHODS
    //////////////////////////////////////////////////////////////*/

  	/// @inheritdoc IWitnessFactory
	function getDeterministicAddress(address _sender) external view returns (address) {
		bytes32 salt = keccak256(abi.encode(_sender, _nonces[_sender]));
		return LibClone.predictDeterministicAddress(implementation, salt, address(this));
	}

	/*//////////////////////////////////////////////////////////////
                        	INTERNAL METHODS
    //////////////////////////////////////////////////////////////*/

	/// @dev Emits an {ImplementationUpdated} event.
	/// @param _implementation The address of the new core contract.
	function _setImplementation(address _implementation) internal {
		implementation = _implementation;
		emit ImplementationUpdated(_implementation);
	}
}
