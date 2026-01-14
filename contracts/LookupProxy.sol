// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.28;

import {IERC165} from "./interface/IERC165.sol";
import {IERC173} from "./interface/IERC173.sol";
import {IDiamondCut} from "./interface/IDiamondCut.sol";

import {CommonStorage} from "./libs/CommonStorage.sol";

import {UpgradeableProxy} from "./upgrade/UpgradeableProxy.sol";

/// @title Lookup Proxy Contract
/// @author AdeThorMiwa
/// @notice This contract handles the proxy functionality for implementation lookup, allowing for upgrades and initialization.
/// @dev Extends the `UpgradeableProxy` contract and registers contract implementation on initiation.
contract LookupProxy is UpgradeableProxy {
    /// @notice Constructs the implementation lookup proxy contract
    /// @dev Initializes the lookup proxy with the provided parameters and sets up supported interfaces.
    /// @param owner Proxy owner account address
    /// @param proxyAdmin Proxy admin contract/account address
    /// @param implementationAddress Implementation contract address
    constructor(
        address owner,
        address proxyAdmin,
        address implementationAddress
    ) UpgradeableProxy(implementationAddress, proxyAdmin) {
        CommonStorage._setOwner(owner);

        // Setup supported interfaces
        CommonStorage._setSupportedInterface(type(IERC165).interfaceId, true);
        CommonStorage._setSupportedInterface(type(IERC173).interfaceId, true);
        CommonStorage._setSupportedInterface(
            type(IDiamondCut).interfaceId,
            true
        );
    }
}
