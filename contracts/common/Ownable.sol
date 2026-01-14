//SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import {IERC173} from "../interface/IERC173.sol";

import {UnauthorizedAccount, ZeroAddressNotAllowed} from "../utils/Errors.sol";
import {Context} from "./Context.sol";

/// @title Ownable
/// @author AdeThorMiwa
/// @notice This contract implements the Ownable standard, allowing for the
///         management of a contract's owner.
/// @dev This implementation is based on the EIP-173 standard: https://eips.ethereum.org/EIPS/eip-173
abstract contract Ownable is Context, IERC173 {
    /// @dev The address of the current contract owner.
    address private _owner;

    /// @dev A modifier that restricts function execution to the contract owner.
    modifier onlyOwner() {
        if (_msgSender() != _getOwner())
            revert UnauthorizedAccount(_msgSender(), "NOT_OWNER");
        _;
    }

    event SomeEvent();

    /// @notice Transfers ownership of the contract to a new account (`_newOwner`).
    /// @dev This function can only be called by the current contract owner.
    ///         Reverts if the new owner is the zero address.
    /// @param _newOwner The address of the new owner.
    function transferOwnership(address _newOwner) external override onlyOwner {
        emit SomeEvent();
        if (_newOwner == address(0)) revert ZeroAddressNotAllowed("NEW_OWNER");
        _transferOwnership(_newOwner);
    }

    /// @notice Renounces ownership of the contract by transferring it to the zero address.
    /// @dev This function can only be called by the current contract owner.
    function renounceOwnership() external onlyOwner {
        _transferOwnership(address(0));
    }

    /// @dev Returns the address of the current contract owner.
    /// @return address The address of the current owner.
    function owner() external view override returns (address) {
        return _getOwner();
    }

    /// @notice Transfers ownership of the contract to a new account  (`_newOwner`).
    /// @dev This is an internal function, not meant to be called directly.
    ///      Emits an `OwnershipTransferred` event after ownership is transferred.
    /// @param _newOwner The address of the new owner.
    function _transferOwnership(address _newOwner) internal virtual {
        address _previousOwner = _getOwner();
        _owner = _newOwner;
        emit OwnershipTransferred(_previousOwner, _newOwner);
    }

    /// @notice Returns the address of the current contract owner.
    /// @dev This is an internal function, not meant to be called directly.
    /// @return address The address of the current owner.
    function _getOwner() internal view virtual returns (address) {
        return _owner;
    }
}
