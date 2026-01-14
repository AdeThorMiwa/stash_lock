//SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.28;

import {IFactory} from "../interface/IFactory.sol";
import {SafeERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {SCSStorage} from "../libs/SCSStorage.sol";
import {Types} from "../libs/Types.sol";
import {CommonStorage} from "../libs/CommonStorage.sol";
import {CheckAddress} from "../libs/CheckAddress.sol";
import {StashBase} from "./StashBase.sol";
import {InvalidMessageValue, ActionRejected, InvalidTokenContractAddress, InvalidOperationAmount} from "../utils/Errors.sol";

import {UseValue} from "../common/UseValue.sol";

/// @title StashDepositBase
/// @author AdeThorMiwa
/// @notice Abstract base contract for handling stash deposit related operations.
/// @dev This contract provides core functionalities for deposit.
abstract contract StashDepositBase is UseValue, StashBase {
    using SafeERC20 for IERC20;
    using CheckAddress for address;

    event TokenDeposited(
        address indexed stash,
        address indexed depositor,
        address indexed token,
        uint256 amount
    );

    function _deposit(uint256 _amount) internal {
        uint256 _refund;
        _beforeDeposit(_amount);

        if (_msgValue() < _amount)
            revert InvalidMessageValue("NOT_ENOUGH_VALUE");

        if (_msgValue() > _amount) {
            unchecked {
                _refund = _msgValue() - _amount;
            }
            sendValue(_msgSender(), _refund);
        }

        emit TokenDeposited(address(this), _msgSender(), address(0), _amount);
    }

    function _deposit(IERC20 _token, uint256 _amount) internal {
        _beforeDeposit(_amount);

        if (!address(_token).hasContractCode())
            revert InvalidTokenContractAddress(address(_token));

        // Transfer token to stash - Reverts on failure
        _token.safeTransferFrom(_msgSender(), address(this), _amount);

        emit TokenDeposited(
            address(this),
            _msgSender(),
            address(_token),
            _amount
        );
    }

    function _beforeDeposit(uint256 amount) internal view {
        if (SCSStorage._status() == Types.StashStatus.CLOSED)
            revert ActionRejected("STASH_DEPOSIT: STASH_CLOSED");

        if (amount == 0)
            revert InvalidOperationAmount("STASH_DEPOSIT: ZERO_AMOUNT", amount);
    }
}
