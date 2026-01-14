//SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.28;

import {IERC165} from "./IERC165.sol";
import {IERC173} from "./IERC173.sol";

/// @title IFactory
/// @author AdeThorMiwa
/// @notice Interface for managing stash.
/// @dev Provides functions for creating, managing, and querying stash.
interface IFactory is IERC173, IERC165 {
    /// @dev Emitted when a new stash is created.
    /// @param owner The address of the stash owner.
    /// @param stash The address of the newly created stash.
    /// @param index The index of the stash within the owner's stashes.
    event StashCreated(
        address indexed owner,
        address indexed stash,
        uint256 indexed index
    );

    /// @dev Emitted when stash this deployed to a location.
    /// @param owner The address of the stash owner.
    /// @param stash The address of the newly created stash.
    /// @param index The index of the stash within the owner's stashes.
    event StashDeployed(
        address indexed owner,
        address indexed stash,
        uint256 indexed index
    );

    /// @dev Creates a new stash for the message sender.
    function createStash() external;

    /// @dev Creates a new stash for a specific owner.
    /// @param _ownerAddress The address of the owner.
    function createStash(address _ownerAddress) external;

    /// @dev Checks if a given address is a stash.
    /// @param _stash The address to check.
    /// @return True if the address is a stash, false otherwise.
    function isStash(address _stash) external view returns (bool);

    /// @dev Returns the address of the lookup proxy contract.
    /// @return The address of the lookup proxy contract.
    function getLookupProxy() external view returns (address);

    /// @dev Returns an array of stash owned by a given address.
    /// @param _ownerAddress The address of the stash owner.
    /// @return stashes An array of stash addresses.
    /// @return currentCount The number of stash owned by the address.
    function getStashes(
        address _ownerAddress
    ) external view returns (address[] memory stashes, uint256 currentCount);
}
