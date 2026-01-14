//SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.28;

import {CheckCallResult} from "../libs/CheckCallResult.sol";

import {NotEnoughBalance} from "../utils/Errors.sol";

/// @title UseValue
/// @author AdeThorMiwa
/// @notice Abstract contract providing utility functions for handling native Ether.
/// @dev This contract offers functions to retrieve the contract's Ether balance using
///      `selfBalance()` and send Ether to external addresses using `sendValue()`.
abstract contract UseValue {
    using CheckCallResult for bool;

    /// @dev Sends Ether to a specified recipient address.
    /// @param _recipient The address to receive the Ether.
    /// @param _value The amount of Ether to send.
    /// @dev Reverts with `NotEnoughBalance` if the contract's balance is insufficient.
    function sendValue(address _recipient, uint256 _value) internal virtual {
        if (selfBalance() < _value) {
            revert NotEnoughBalance(
                address(this),
                _recipient,
                selfBalance(),
                _value,
                address(0)
            );
        }

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returnData) = payable(_recipient).call{
            value: _value
        }("");

        success.verifyCallResult(returnData, "SEND_VALUE_FAILED");
    }

    /// @dev Returns the contract's native Ether balance.
    /// @return _balance The amount of Ether held by the contract.
    function selfBalance() internal view virtual returns (uint256 _balance) {
        // solhint-disable-next-line no-inline-assembly
        assembly {
            _balance := selfbalance()
        }
    }
}
