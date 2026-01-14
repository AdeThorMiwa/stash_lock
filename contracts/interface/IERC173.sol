// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

/// @title IERC173: Contract Ownership
/// @author AdeThorMiwa
/// @notice Interface for the ERC-173 Contract Ownership Standard.
/// @dev See https://eips.ethereum.org/EIPS/eip-173 for more details.
interface IERC173 {
    /// @dev Emitted when ownership of the contract is transferred.
    /// @param previousOwner The address of the previous owner.
    /// @param newOwner The address of the new owner.
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /// @notice Transfers ownership of the contract to a new address.
    /// @dev Setting `newOwner` to the zero address renounces ownership.
    /// @param _newOwner The address of the new owner.
    function transferOwnership(address _newOwner) external;

    /// @dev Returns the address of the current contract owner.
    /// @return owner The address of the contract owner.
    function owner() external view returns (address);
}
