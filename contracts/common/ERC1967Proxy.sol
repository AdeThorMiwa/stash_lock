// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import {Proxy} from "./Proxy.sol";
import {ERC1967Upgrade} from "./ERC1967Upgrade.sol";

/// @title ERC1967 Proxy
/// @notice Implements a proxy contract based on the ERC1967 upgradeable proxy standard.
/// @dev This contract acts as a proxy for delegating calls to an implementation contract.
///      It supports upgrades using the ERC1967 upgrade mechanism.
abstract contract ERC1967Proxy is Proxy, ERC1967Upgrade {
    /// @dev Initializes an ERC1967 proxy with a given implementation contract and optional initialization data.
    ///
    /// Deploys the proxy and calls the `_upgradeToAndCall` function of the ERC1967Upgrade
    /// contract to set the initial implementation and optionally execute data.
    ///
    /// Requirements:
    /// - `_logic` must be a non-zero address.
    constructor(address _logic, bytes memory _data) payable {
        assert(
            _IMPLEMENTATION_SLOT ==
                bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1)
        );
        _upgradeToAndCall(_logic, _data);
    }

    /// @dev Returns the current implementation address stored in this proxy.
    ///
    /// This function is an internal implementation detail and should generally not be used
    /// directly by user applications.
    function _implementation()
        internal
        view
        virtual
        override
        returns (address impl)
    {
        return ERC1967Upgrade._getImplementation();
    }
}
