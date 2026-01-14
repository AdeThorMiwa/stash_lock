// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.28;

import {CommonStorage} from "../libs/CommonStorage.sol";

import {Ownable} from "../common/Ownable.sol";

/// @title Ownable Operations Contract
/// @author AdeThorMiwa
/// @notice This contract extends the Ownable functionality, utilizing CommonStorage for owner management.
/// @dev Overrides Ownable functions to use CommonStorage for storing and retrieving the owner.
contract OwnableOps is Ownable {
    /// @notice Overrides the _transferOwnership function from Ownable to use CommonStorage.
    /// @inheritdoc Ownable
    function _transferOwnership(address _newOwner) internal override {
        CommonStorage._setOwner(_newOwner);
    }

    /// @notice Overrides the _getOwner function from Ownable to use CommonStorage.
    /// @inheritdoc Ownable
    function _getOwner() internal view override returns (address) {
        return CommonStorage._getOwner();
    }
}
