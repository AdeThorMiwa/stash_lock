//SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.28;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title IStashDeposit
/// @author AdeThorMiwa
/// @notice Interface for deposit functionalities within an stash system.
/// @dev Defines functions for deposit
interface IStashDeposit {
    /// @dev Deposits native token into a stash.
    /// @param _amount The amount of the specified token to deposit.
    /// @custom:signature deposit(uint256)
    function deposit(uint256 _amount) external payable;

    /// @dev Deposits a specified ERC20 token into a stash.
    /// @param _token The ERC20 token address being deposited into the stash.
    /// @param _amount The amount of the specified token to deposit.
    /// @custom:signature deposit(address,uint256)
    function deposit(IERC20 _token, uint256 _amount) external;
}
