//SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.28;

import {IFactory} from "../interface/IFactory.sol";
import {SafeERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {SCSStorage} from "../libs/SCSStorage.sol";
import {Types} from "../libs/Types.sol";
import {CommonStorage} from "../libs/CommonStorage.sol";
import {CheckAddress} from "../libs/CheckAddress.sol";
import {StashBase} from "./StashBase.sol";
import {InvalidMessageValue, ActionRejected, InvalidTokenContractAddress, InvalidOperationAmount, InvalidWithdrawalRecipient} from "../utils/Errors.sol";

import {UseValue} from "../common/UseValue.sol";

/// @title StashWithdrawalBase
/// @author AdeThorMiwa
/// @notice Abstract base contract for handling stash withdrawal operations.
/// @dev This contract provides core functionalities for withdrawals for both native and ERC20 tokens. It also handles
///      policy checks for withdrawals.
abstract contract StashWithdrawalBase is UseValue, StashBase {
    using SafeERC20 for IERC20;
    using CheckAddress for address;

    event TokenWithdrawn(
        address indexed stash,
        address indexed recipient,
        address indexed token,
        uint256 amount
    );

    function _withdraw(uint256 _amount, address _recipient) internal {
        _beforeWithdrawal(_amount, _recipient);

        sendValue(_recipient, _amount);

        emit TokenWithdrawn(address(this), _recipient, address(0), _amount);
    }

    function _withdraw(
        IERC20 _token,
        uint256 _amount,
        address _recipient
    ) internal {
        _beforeWithdrawal(_token, _amount, _recipient);

        // Transfer token to _recipeint - Reverts on failure
        _token.safeTransfer(_recipient, _amount);

        emit TokenWithdrawn(
            address(this),
            _recipient,
            address(_token),
            _amount
        );
    }

    function _beforeWithdrawal(
        IERC20 _token,
        uint256 _amount,
        address _recipient
    ) internal view virtual {
        if (!address(_token).hasContractCode())
            revert InvalidTokenContractAddress(address(_token));
        _beforeWithdrawal(_amount, _recipient);
    }

    function _beforeWithdrawal(
        uint256 _amount,
        address _recipient
    ) internal view {
        if (SCSStorage._status() == Types.StashStatus.CLOSED)
            revert ActionRejected("STASH_WITHDRAWAL: STASH_CLOSED");

        if (_amount == 0)
            revert InvalidOperationAmount(
                "STASH_WITHDRAWAL: ZERO_AMOUNT",
                _amount
            );

        if (_recipient == address(0))
            revert InvalidWithdrawalRecipient(_recipient);

        _enforceWithdrawalPolicy();
    }

    function _enforceWithdrawalPolicy() internal view {
        // allow all for now
    }
}
