// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.28;

import {ILookup} from "../interface/ILookup.sol";
import {IDiamondCut, Types} from "../interface/IDiamondCut.sol";

import {LookupStorage, CheckAddress} from "../libs/LookupStorage.sol";
import {CommonStorage} from "../libs/CommonStorage.sol";

import {InvalidLookupImplementation, NotContractAddress, InvalidImplementationLockKey} from "../utils/Errors.sol";
import {Ownable} from "../common/Ownable.sol";

/// @title LookupOps Contract
/// @author AdeThorMiwa
/// @notice This contract manages lookup operations for implementations, including the diamond cut process and implementation locking.
/// @dev Lookup is based on function signature mapping to implementation contract
contract LookupOps is Ownable, ILookup, IDiamondCut {
    using CheckAddress for address;

    /// @notice Locks an implementation to a specific contract identifier.
    /// @dev Reverts if the implementation does not have contract code or if the lock key is zero.
    /// @param _implementation The implementation address to lock.
    /// @param _lockKey The lock key to use.
    function lockImplementation(
        address _implementation,
        bytes8 _lockKey
    ) external override onlyOwner {
        if (!_implementation.hasContractCode())
            revert NotContractAddress(_implementation);
        if (_lockKey == bytes8(0))
            revert InvalidImplementationLockKey(_lockKey);
        LookupStorage._setLockState(_implementation, true);
        LookupStorage._setLockKey(_implementation, _lockKey);
    }

    /// @notice Sets global use support for an implementation.
    /// @dev Reverts if the implementation does not have contract code.
    /// @param _implementation The implementation address to update.
    /// @param _allowGlobal True to allow global use, false otherwise.
    function setGlobalUse(
        address _implementation,
        bool _allowGlobal
    ) external override onlyOwner {
        if (!_implementation.hasContractCode())
            revert NotContractAddress(_implementation);
        LookupStorage._setGlobalState(_implementation, _allowGlobal);
    }

    /// @notice Registers an array of facet cuts (implementations) for the diamond cut.
    /// @dev This function handles the diamond cut and emits a DiamondCut event.
    /// @param _diamondCut An array of facet cuts to apply.
    function diamondCut(
        Types.FacetCut[] calldata _diamondCut
    ) external override onlyOwner {
        LookupStorage._handleDiamondCut(_diamondCut);
        emit DiamondCut(_diamondCut, address(0), "");
    }

    /// @notice Registers implementations and performs an initialization call to a target address.
    /// @dev This function handles the diamond cut, performs the initialization call, and emits a DiamondCut event.
    /// @param _diamondCut An array of facet cuts to apply.
    /// @param _initTarget The target address for the initialization call.
    /// @param _initCalldata The calldata to execute on the initialization call.
    function diamondCut(
        Types.FacetCut[] calldata _diamondCut,
        address _initTarget,
        bytes calldata _initCalldata
    ) external override onlyOwner {
        LookupStorage._handleDiamondCut(_diamondCut);
        LookupStorage._handleInitCall(_initTarget, _initCalldata);
        emit DiamondCut(_diamondCut, _initTarget, _initCalldata);
    }

    /// @notice Retrieves the implementation address for a given function signature.
    /// @dev Reverts if the implementation is locked to a specific contract.
    /// @param _signature The function signature to look up.
    /// @return implementation The address of the implementation.
    function getImplementation(
        bytes4 _signature
    ) external view override returns (address implementation) {
        implementation = LookupStorage._signatureImplementation(_signature);
        // Ensure implementation is not locked to specific
        if (LookupStorage._getLockState(implementation)) {
            revert InvalidLookupImplementation(implementation, _signature);
        }
    }

    /// @notice Retrieves the implementation address for a given function signature and lock key.
    /// @dev Reverts if the implementation is not locked to the specified key.
    /// @param _signature The function signature to look up.
    /// @param _lockKey The lock key to check against.
    /// @return implementation The address of the implementation.
    function getImplementation(
        bytes4 _signature,
        bytes8 _lockKey
    ) external view override returns (address implementation) {
        implementation = LookupStorage._signatureImplementation(_signature);
        // Ensure implementation is not locked to specific
        if (!LookupStorage._getGlobalState(implementation)) {
            if (LookupStorage._getLockKey(implementation) != _lockKey) {
                revert InvalidLookupImplementation(implementation, _signature);
            }
        }
    }

    /// @notice Checks if the contract supports a given interface.
    /// @param _interfaceId The interface ID to check.
    /// @return bool True if the interface is supported, false otherwise.
    function supportsInterface(
        bytes4 _interfaceId
    ) external view override returns (bool) {
        return CommonStorage._getSupportedInterface(_interfaceId);
    }

    /// @notice Transfers ownership of the contract to a new address.
    /// @dev This function is called internally and updates the ownership in CommonStorage.
    /// @param _newOwner The address of the new owner.
    function _transferOwnership(address _newOwner) internal override {
        CommonStorage._setOwner(_newOwner);
    }

    /// @notice Gets the current contract owner.
    /// @dev This function is called internally and retrieves the owner from CommonStorage.
    /// @return The address of the current owner.
    function _getOwner() internal view override returns (address) {
        return CommonStorage._getOwner();
    }
}
