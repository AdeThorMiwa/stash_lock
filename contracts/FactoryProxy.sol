//SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.28;

import {IERC165} from "./interface/IERC165.sol";
import {IERC173} from "./interface/IERC173.sol";

import {CommonStorage} from "./libs/CommonStorage.sol";
import {FactoryStorage} from "./libs/FactoryStorage.sol";

import {UpgradeableProxy} from "./upgrade/UpgradeableProxy.sol";

/// @title Factory Proxy Contract
/// @author AdeThorMiwa
/// @notice This contract handles the proxy functionality for the stash factory, allowing for upgrades and initialization.
/// @dev Extends the `UpgradeableProxy` contract and registers contract implementation on initiation.
contract FactoryProxy is UpgradeableProxy {
    /// @notice Constructs the stash factory proxy contract
    /// @dev Initializes the factory proxy with the provided parameters and sets up supported interfaces.
    /// @param owner Factory contract proxy owner address
    /// @param proxyAdmin Factory proxy admin address
    /// @param implementation Factory implementation contract address
    /// @param stashLookup Stash lookup contract address
    /// @param userMaxStash user stash limit
    constructor(
        address owner,
        address proxyAdmin,
        address implementation,
        address stashLookup,
        uint16 userMaxStash
    ) UpgradeableProxy(implementation, proxyAdmin) {
        CommonStorage._setOwner(owner);
        CommonStorage._setLookupProxy(stashLookup);
        FactoryStorage._setUserMaxStash(userMaxStash);

        CommonStorage._setSupportedInterface(type(IERC165).interfaceId, true);
        CommonStorage._setSupportedInterface(type(IERC173).interfaceId, true);
    }
}
