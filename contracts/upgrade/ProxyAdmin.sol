//SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.28;

import {CheckCallResult} from "../libs/CheckCallResult.sol";

import {ZeroAddressNotAllowed} from "../utils/Errors.sol";
import {Ownable} from "../common/Ownable.sol";
import {UpgradeableProxy} from "./UpgradeableProxy.sol";

/// @title ProxyAdmin Contract
/// @author AdeThorMiwa
/// @notice This contract manages the upgradeability and administration of proxy contracts.
/// @dev It allows the owner to change the proxy admin, upgrade the proxy implementation, and perform upgrade and call operations.
contract ProxyAdmin is Ownable {
    using CheckCallResult for bool;

    /// @dev Instantiates ProxyAdmin and explicityl sets the owner.
    /// @param owner_ The address of the owner.
    constructor(address owner_) {
        if (owner_ == address(0)) revert ZeroAddressNotAllowed("OWNER");
        _transferOwnership(owner_);
    }

    /// @dev Upgrades `proxy` to `implementation`.
    /// Requirements:
    /// - This contract must be the admin of `proxy`.
    /// @param proxy The address of the `UpgradeableProxy` contract.
    /// @param implementation The address of the new implementation.
    function upgrade(
        UpgradeableProxy proxy,
        address implementation
    ) external onlyOwner {
        proxy.upgradeTo(implementation);
    }

    /// @dev Upgrades `proxy` to `implementation` and calls a function on the new implementation.
    /// See {UpgradeableProxy-upgradeToAndCall}.
    /// Requirements:
    /// - This contract must be the admin of `proxy`.
    /// @param proxy The address of the `UpgradeableProxy` contract.
    /// @param implementation The address of the new implementation.
    /// @param data The data to call the new implementation with.
    function upgradeAndCall(
        UpgradeableProxy proxy,
        address implementation,
        bytes memory data
    ) external payable onlyOwner {
        proxy.upgradeToAndCall{value: msg.value}(implementation, data);
    }

    /// @dev Changes the admin of `proxy` to `newAdmin`.
    /// Requirements:
    /// - This contract must be the current admin of `proxy`.
    /// @param proxy The address of the `UpgradeableProxy` contract.
    /// @param newAdmin The address of the new admin.
    function changeProxyAdmin(
        UpgradeableProxy proxy,
        address newAdmin
    ) external onlyOwner {
        proxy.changeAdmin(newAdmin);
    }

    /// @dev Returns the current admin address of `proxy`.
    /// Requirements:
    /// - This contract must be the admin of `proxy`.
    /// @param proxy The address of the `UpgradeableProxy` contract.
    /// @return The address of the current admin.
    function getProxyAdmin(
        UpgradeableProxy proxy
    ) external view returns (address) {
        // We need to manually run the static call since the getter cannot be flagged as view
        // bytes4(keccak256("admin()")) == 0xf851a440
        (bool success, bytes memory returndata) = address(proxy).staticcall(
            hex"f851a440"
        );
        success.verifyCallResult(returndata, "PROXY_ADMIN: CALL_FAILED");
        return abi.decode(returndata, (address));
    }

    /// @dev Returns the current implementation address of `proxy`.
    /// Requirements:
    /// - This contract must be the admin of `proxy`.
    /// @param proxy The address of the `UpgradeableProxy` contract.
    /// @return The address of the current implementation.
    function getProxyImplementation(
        UpgradeableProxy proxy
    ) external view returns (address) {
        // We need to manually run the static call since the getter cannot be flagged as view
        // bytes4(keccak256("implementation()")) == 0x5c60da1b
        (bool success, bytes memory returndata) = address(proxy).staticcall(
            hex"5c60da1b"
        );

        success.verifyCallResult(returndata, "PROXY_ADMIN: CALL_FAILED");
        return abi.decode(returndata, (address));
    }
}
