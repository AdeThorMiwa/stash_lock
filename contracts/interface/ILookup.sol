//SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.28;

import {IERC165} from "./IERC165.sol";
import {IERC173} from "./IERC173.sol";

/// @title ILookup
/// @author AdeThorMiwa
/// @notice Interface for managing implementation lookup.
/// @dev Provides functions for retrieving and managing implementations based on function signatures.
interface ILookup is IERC165, IERC173 {
    /// @dev Locks an implementation with a specific lock key.
    /// @param _implementation The address of the implementation.
    /// @param _lockKey The lock key for the implementation.
    function lockImplementation(
        address _implementation,
        bytes8 _lockKey
    ) external;

    /// @dev Sets the global usage flag for an implementation.
    /// @param _implementation The address of the implementation.
    /// @param _allowGlobal Whether the implementation can be used globally.
    function setGlobalUse(address _implementation, bool _allowGlobal) external;

    /// @dev Returns the implementation address for a given function signature.
    /// @param _signature The function signature.
    /// @return implementation The address of the implementation.
    function getImplementation(
        bytes4 _signature
    ) external view returns (address implementation);

    /// @dev Returns the implementation address for a given function signature and lock key.
    /// @param _signature The function signature.
    /// @param _lockKey The lock key for the implementation.
    /// @return implementation The address of the implementation.
    function getImplementation(
        bytes4 _signature,
        bytes8 _lockKey
    ) external view returns (address implementation);
}
