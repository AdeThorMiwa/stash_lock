// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.28;

/// @title Context
/// @author AdeThorMiwa
/// @notice This contract is an abstract base contract that provides
///         commonly used functions for accessing message information from the current context.
/// @dev It is intended to be inherited by other contracts that need access to
///      `msg.sender`, `msg.data`, `msg.sig`, and `msg.value`.
abstract contract Context {
    /// @dev Returns the message sender address from the current context.
    /// @return msgSender The address of the message sender.
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    /// @dev Returns the message value (in wei) of the current context.
    /// @return msgValue The value of the message in wei.
    function _msgValue() internal view virtual returns (uint256) {
        return msg.value;
    }
}
