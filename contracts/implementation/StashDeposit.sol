//SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.28;

import {IStashDeposit} from "../interface/IStashDeposit.sol";
import {StashDepositBase, CheckAddress} from "../common/StashDepositBase.sol";
import {SafeERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/// @title StashDeposit
/// @author AdeThorMiwa
/// @notice Facilitates deposits to stash for native and ERC20 tokens.
/// @dev Manages stash deposits and event propagation.
contract StashDeposit is StashDepositBase, IStashDeposit {
    using CheckAddress for address;
    using SafeERC20 for IERC20;

    /// @notice Deposit to stash using native currency.
    /// @dev Calls `_deposit` to handle the deposit of native currency.
    /// @inheritdoc IStashDeposit
    function deposit(uint256 _amount) external payable override {
        _deposit(_amount);
    }

    /// @notice Deposit to stash using an ERC20 token.
    /// @dev Calls `_deposit` to handle the deposit of an ERC20 token.
    /// @inheritdoc IStashDeposit
    function deposit(IERC20 _token, uint256 _amount) external override {
        _deposit(_token, _amount);
    }
}
