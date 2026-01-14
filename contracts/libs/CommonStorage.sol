// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.28;

import {InvalidInputData, ZeroAddressNotAllowed, UnauthorizedAccount} from "../utils/Errors.sol";

/// @title CommonStorage Library
/// @author AdeThorMiwa
/// @notice Provides a storage structure and utility functions for managing common storage data.
/// @dev This library contains functions for setting and getting various contract addresses,
///      enforcing ownership, and managing supported interfaces.
library CommonStorage {
    /// @dev Structure representing common storage used in the contract.
    struct CStorage {
        // The address of the owner, which is payable.
        address payable owner;
        // The address of the lookup proxy.
        address lookupProxy;
        // The address of the factory.
        address factory;
        // A mapping to track supported interfaces, using function selectors as keys and boolean values.
        mapping(bytes4 => bool) supportedInterfaces;
    }

    /// @dev Random storage slot
    bytes32 internal constant COMMON_STORAGE_SLOT =
        keccak256("com.stash.common.storage");

    /// @dev This emits when ownership of a contract changes.
    /// @param previousOwner The address of the previous owner.
    /// @param newOwner The address of the new owner.
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /// @dev Lookup proxy change event.
    /// @param previousProxy The address of the previous proxy.
    /// @param newProxy The address of the new proxy.
    event LookupProxyChanged(
        address indexed previousProxy,
        address indexed newProxy
    );

    /// @dev Sets the factory address.
    /// @param _factory The new factory address.
    function _setFactory(address _factory) internal {
        if (_factory == address(0))
            revert ZeroAddressNotAllowed("PROTOCOL_FACTORY");

        CStorage storage cs = cStore();
        cs.factory = _factory;
    }

    /// @dev Sets the contract owner.
    /// @param _owner The new owner address.
    function _setOwner(address _owner) internal {
        if (_owner == address(0)) revert ZeroAddressNotAllowed("OWNER");

        address previousOwner = _getOwner();
        CStorage storage cs = cStore();
        cs.owner = payable(_owner);
        emit OwnershipTransferred(previousOwner, _owner);
    }

    /// @dev Sets the current stash lookup contract.
    /// @param _lookupProxy The new stash lookup contract address.
    function _setLookupProxy(address _lookupProxy) internal {
        if (_lookupProxy == address(0))
            revert ZeroAddressNotAllowed("LOOKUP_PROXY");

        address previousProxy = _getLookupProxy();
        CStorage storage cs = cStore();
        cs.lookupProxy = _lookupProxy;
        emit LookupProxyChanged(previousProxy, _lookupProxy);
    }

    /// @dev Sets whether a specific interface is supported.
    /// @param _interfaceId The interface ID.
    /// @param _supported True if the interface is supported, false otherwise.
    function _setSupportedInterface(
        bytes4 _interfaceId,
        bool _supported
    ) internal {
        if (_interfaceId == bytes4(0))
            revert InvalidInputData("_interfaceId", "INVALID_LENGTH");

        CStorage storage cs = cStore();
        cs.supportedInterfaces[_interfaceId] = _supported;
    }

    /// @dev Gets whether a specific interface is supported.
    /// @param _interfaceId The interface ID.
    /// @return supported True if the interface is supported, false otherwise.
    function _getSupportedInterface(
        bytes4 _interfaceId
    ) internal view returns (bool supported) {
        supported = cStore().supportedInterfaces[_interfaceId];
    }

    /// @dev Gets the current stash lookup contract.
    /// @return lookupProxy The current stash lookup address.
    function _getLookupProxy() internal view returns (address lookupProxy) {
        lookupProxy = cStore().lookupProxy;
    }

    /// @dev Ensures the message sender is the current contract owner.
    function enforceIsOwner() internal view {
        if (msg.sender != _getOwner())
            revert UnauthorizedAccount(msg.sender, "NOT_OWNER");
    }

    /// @dev Gets contract owner.
    /// @return owner The address of the owner.
    function _getOwner() internal view returns (address owner) {
        owner = cStore().owner;
    }

    /// @dev Gets the factory contract Address.
    /// @return factory The address of the factory contract.
    function _getFactory() internal view returns (address factory) {
        factory = cStore().factory;
    }

    /// @dev Retrieves the storage structure.
    /// @return sc The storage structure.
    function cStore() internal pure returns (CStorage storage sc) {
        bytes32 pos = COMMON_STORAGE_SLOT;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            sc.slot := pos
        }
    }
}
