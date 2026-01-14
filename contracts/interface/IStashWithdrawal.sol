//SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.28;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title IStashWithdrawal
/// @author AdeThorMiwa
/// @notice Interface for withdrawal functionalities within an stash system.
/// @dev Defines functions for withdrawal
interface IStashWithdrawal {
    /// @dev Withdraw native token from a stash.
    /// @param _amount The amount of the specified token to withdraw.
    /// @param _recipient The recipient of the withdrawn amount
    /// @custom:signature withdraw(uint256,address)
    function withdraw(uint256 _amount, address _recipient) external payable;

    /// @dev Withdraw a specified ERC20 token from a stash.
    /// @param _token The ERC20 token address being withdrawn from the stash.
    /// @param _amount The amount of the specified token to withdraw.
    /// @param _recipient The recipient of the withdrawn amount
    /// @custom:signature withdrawal(address,uint256,address)
    function withdraw(
        IERC20 _token,
        uint256 _amount,
        address _recipient
    ) external;
}
