// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

/// @title IWitnessFactory
/// @author swa.eth
/// @notice Interface for the Witness Factory smart contract.
interface IWitnessFactory {
	/*//////////////////////////////////////////////////////////////
                            CUSTOM ERRORS
    //////////////////////////////////////////////////////////////*/

	/// @notice Thrown when the owner address provided is the zero address.
	error InvalidOwnerZeroAddress();

  	/*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

  	/// @notice Emitted when the core implementation contract is updated.
  	/// @param _implementation The newly accepted tree root hash.
	event ImplementationUpdated(address _implementation);

	/// @notice Emitted when new core contract is created.
  	/// @param _witnessId The counter ID mapping to the newly created instance contract.
  	/// @param _clone The address of the newly created instance contract.
	/// @param _owner The address that should be set as the initial contract owner.
	event WitnessCreated(uint96 _witnessId, address _clone, address _owner);

	/*//////////////////////////////////////////////////////////////////////////
                                READ METHODS
    //////////////////////////////////////////////////////////////////////////*/
	
	/// @notice Returns the constant value of the system admin role.
	function ADMIN_ROLE() external view returns (uint256);

  	/// @notice Gets the deterministic contract address for a given sender based on their current nonce.
  	/// @param _sender The address of the deployer that would be creating a new Witness contract.
 	/// @return The address of their next instance contract.
	function getDeterministicAddress(address _sender) external view returns (address);

	/// @notice Returns the address of the current core implementation contract.
	function implementation() external view returns (address);

	/// @notice Incremental counter used for tracking instance contracts.
	function instanceId() external view returns (uint96);

	/// @notice Mapping of instance ID to the instance contract address.
	function instances(uint96) external view returns (address);

  	/*//////////////////////////////////////////////////////////////
                              WRITE METHODS
    //////////////////////////////////////////////////////////////*/

	/// @notice Updates the current Witness implementation contract used for creating new instances.
	/// @dev Emits an {ImplementationUpdated} event.
  	/// @param _implementation The address of the new core contract.
	function setImplementation(address _implementation) external;

  	/// @notice Creates a new core Witness instacne.
	/// @dev Emits a {WitnessCreated} event.
  	/// @param _owner The address that should be set as the initial contract owner.
	/// @param _size The initial size of the merkle tree.
	/// @param _range The initial range of the merkle tree.
 	/// @return The address of the newly created core contract.
	function createWitness(address _owner, uint256 _size, bytes32[] calldata _range) external returns (address);
}
