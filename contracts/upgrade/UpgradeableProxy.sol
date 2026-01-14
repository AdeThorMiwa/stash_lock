//SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.28;

import {ZeroAddressNotAllowed, ActionRejected, InvalidInputData} from "../utils/Errors.sol";
import {ERC1967Proxy} from "../common/ERC1967Proxy.sol";

/// @title UpgradeableProxy Contract
/// @author AdeThorMiwa
/// @notice This contract implements an upgradeable proxy that uses the ERC1967 standard.
/// @dev It includes functions to upgrade the implementation and manage the admin role.
abstract contract UpgradeableProxy is ERC1967Proxy {
    /// @dev Modifier used internally to delegate the call to the implementation unless the sender is the admin.
    modifier ifAdmin() {
        if (msg.sender == _getAdmin()) {
            _;
        } else {
            _fallback();
        }
    }

    /// @dev Initializes an upgradeable proxy managed by `_admin`, backed by the implementation at `_logic`, and
    ///     Optionally initialized with `_data` as explained in {ERC1967Proxy-constructor}.
    /// @param _logic The address of the initial implementation.
    /// @param admin_ The address of the admin.
    constructor(
        address _logic,
        address admin_
    ) ERC1967Proxy(_logic, bytes("")) {
        assert(
            _ADMIN_SLOT ==
                bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1)
        );
        _changeAdmin(admin_);
    }

    /// @dev Returns the current admin address.
    /// Requirements:
    /// - Only the admin can call this function. See {FactoryProxyAdmin-getProxyAdmin}
    /// TIP: To get this value, clients can read directly from the storage slot specified by EIP1967 using the `eth_getStorageAt` RPC call.
    /// @return admin_ The address of the current admin.
    function admin() external ifAdmin returns (address admin_) {
        admin_ = _getAdmin();
    }

    /// @dev Returns the current implementation address.
    /// Requirements:
    /// - Only the admin can call this function.
    /// TIP: To get this value, clients can read directly from the storage slot specified by EIP1967 using the `eth_getStorageAt` RPC call.
    /// @return implementation_ The address of the current implementation.
    function implementation()
        external
        ifAdmin
        returns (address implementation_)
    {
        implementation_ = _implementation();
    }

    /// @dev Changes the admin of the proxy to `newAdmin`.
    /// Requirements:
    /// - Only the admin can call this function. See {FactoryProxyAdmin-FactoryProxyAdmin}.
    /// - `newAdmin` cannot be the zero address.
    /// Emits an {AdminChanged} event.
    /// @param newAdmin The address of the new admin.
    function changeAdmin(address newAdmin) external virtual ifAdmin {
        if (address(newAdmin) == address(0))
            revert ZeroAddressNotAllowed("NEW_ADMIN");
        _changeAdmin(newAdmin);
    }

    /// @dev Upgrade the implementation of the proxy to `newImplementation`.
    /// Requirements:
    /// - Only the admin can call this function. See {FactoryProxyAdmin-upgrade}.
    /// - `newImplementation` cannot be the zero address.
    /// @param newImplementation The address of the new implementation.
    function upgradeTo(address newImplementation) external ifAdmin {
        if (address(newImplementation) == address(0))
            revert ZeroAddressNotAllowed("IMPLEMENTATION");
        _upgradeToAndCall(newImplementation, bytes(""));
    }

    /// @dev Upgrade the implementation of the proxy to `newImplementation` and call a function from the new implementation.
    /// Requirements:
    /// - Only the admin can call this function. See {FactoryProxyAdmin-upgradeAndCall}.
    /// - `newImplementation` cannot be the zero address.
    /// @param newImplementation The address of the new implementation.
    /// @param data The data to call the new implementation with.

    function upgradeToAndCall(
        address newImplementation,
        bytes calldata data
    ) external payable ifAdmin {
        if (data.length == 0) revert InvalidInputData("data", "ZERO_BYTES");
        if (address(newImplementation) == address(0))
            revert ZeroAddressNotAllowed("IMPLEMENTATION");
        _upgradeToAndCall(newImplementation, data);
    }

    /// @dev Ensures the admin cannot access the fallback function. See {Proxy-_beforeFallback}.
    /// Requirements:
    /// - If the sender is the admin, revert with `ActionRejected`.
    function _beforeFallback() internal virtual override {
        if (msg.sender == _getAdmin())
            revert ActionRejected("UPGRADABLE_PROXY: ADMIN_FALLBACK");
        super._beforeFallback();
    }
}
