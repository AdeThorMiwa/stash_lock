//SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.28;

import {CommonStorage} from "../libs/CommonStorage.sol";

/// @title UseOwner
/// @author AdeThorMiwa
/// @notice Abstract contract providing an onlyOwner modifier for access control.
/// @dev This contract leverages the CommonStorage library to enforce ownership checks.
abstract contract UseOwner {
    /// @notice Modifier restricting function calls to the contract owner.
    /// @dev Reverts with an `UnauthorizedAccount` error if the caller is not the owner.
    modifier onlyOwner() {
        CommonStorage.enforceIsOwner();
        _;
    }
}
