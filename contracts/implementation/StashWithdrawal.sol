//SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.28;

import {StashWithdrawalBase, CheckAddress} from "../common/StashWithdrawalBase.sol";
import {IStashWithdrawal} from "../interface/IStashWithdrawal.sol";
import {SafeERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/// @title StashWithdrawal
/// @author AdeThorMiwa
/// @notice Facilitates withdrawals for native and ERC20 tokens on stash.
/// @dev Manages withdrawal on stash.
contract StashWithdrawal is StashWithdrawalBase, IStashWithdrawal {
    using CheckAddress for address;
    using SafeERC20 for IERC20;

    /// @notice Initiate a withdrawal of native currency on stash.
    /// @dev Calls `_withdraw` to handle the initiation of a withdrawal
    /// @inheritdoc IStashWithdrawal
    function withdraw(
        uint256 _amount,
        address _recipient
    ) external payable override {
        _withdraw(_amount, _recipient);
    }

    /// @notice Initiate a withdrawal of an ERC20 token on stash.
    /// @dev Calls `_withdraw` to handle the initiation of a withdrawal
    /// @inheritdoc IStashWithdrawal
    function withdraw(
        IERC20 _token,
        uint256 _amount,
        address _recipient
    ) external override {
        _withdraw(_token, _amount, _recipient);
    }
}
