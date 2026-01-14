// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

/// @title IERC165
/// @author AdeThorMiwa
/// @notice Interface for the ERC165 standard.
/// @dev This interface allows contracts to declare and query support for specific interfaces.
interface IERC165 {
    /// @dev Returns true if this contract implements the interface defined by `interfaceId`.
    /// @param interfaceId The interface identifier, as specified in ERC-165.
    /// @return True if the contract implements the interface, false otherwise.
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
