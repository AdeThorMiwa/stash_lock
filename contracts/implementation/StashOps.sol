//SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.28;

import {IStashOps} from "../interface/IStashOps.sol";
import {SafeERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {SCSStorage} from "../libs/SCSStorage.sol";
import {CommonStorage} from "../libs/CommonStorage.sol";
import {Types} from "../libs/Types.sol";

import {ActionRejected} from "../utils/Errors.sol";
import {StashBase} from "../common/StashBase.sol";
import {UseValue} from "../common/UseValue.sol";

/// @title StashOps
/// @author AdeThorMiwa
/// @notice Manages operations related to stash.
/// @dev Includes functionalities to manage and interact with stash operations.
contract StashOps is UseValue, StashBase, IStashOps {
    using SafeERC20 for IERC20;

    /// @notice Retrieves the stash balance for native coin.
    /// @dev Fetches native balance from SCSStorage.
    /// @inheritdoc IStashOps
    function balance() external view returns (uint256) {
        return SCSStorage._balance();
    }

    /// @notice Retrieves the stash balance for an ERC20 token
    /// @dev Fetches ERC20 token balance from SCSStorage.
    /// @inheritdoc IStashOps
    function balance(IERC20 _token) external view returns (uint256) {
        return SCSStorage._balance(_token);
    }

    function tokens() external view returns (IERC20[] memory tokensList) {
        tokensList = SCSStorage._tokens();
    }

    /// @notice Sets the stash state to enable or disable owner action.
    /// @dev Only callable by the owner. Emits StashStatusChanged event.
    /// @inheritdoc IStashOps
    function setStatus(Types.StashStatus _status) external override onlyOwner {
        SCSStorage._setStatus(_status);
        emit StashStatusChanged(address(this), _status);
    }

    function status() external view returns (Types.StashStatus _status) {
        _status = SCSStorage._status();
    }

    /// @notice Checks if a specific interface is supported.
    /// @dev Verifies the supported interface in CommonStorage.
    /// @param _interfaceId The interface identifier to check.
    /// @return bool True if the interface is supported, otherwise false.
    function supportsInterface(
        bytes4 _interfaceId
    ) external view returns (bool) {
        return CommonStorage._getSupportedInterface(_interfaceId);
    }
}
