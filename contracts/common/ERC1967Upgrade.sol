// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/ERC1967/ERC1967Upgrade.sol)

pragma solidity 0.8.28;

import {StorageSlot} from "../libs/StorageSlot.sol";
import {CheckAddress} from "../libs/CheckAddress.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";

import {NotContractAddress, ZeroAddressNotAllowed} from "../utils/Errors.sol";

/// @dev This abstract contract provides functionalities for managing storage slots
/// used by the ERC1967 Upgradeable Proxy standard (EIP-1967).
/// It includes functions for getting and setting the implementation address
/// and the admin address.
/// _Available since v4.1._
/// @custom:oz-upgrades-unsafe-allow delegatecall
abstract contract ERC1967Upgrade {
    using Address for address;
    using CheckAddress for address;

    /// @dev Storage slot with the address of the current implementation.
    /// This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1, and is
    /// validated in the constructor.
    bytes32 internal constant _IMPLEMENTATION_SLOT =
        0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /// @dev Storage slot with the admin of the contract.
    /// This is the keccak-256 hash of "eip1967.proxy.admin" subtracted by 1, and is
    /// validated in the constructor.
    bytes32 internal constant _ADMIN_SLOT =
        0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    /// @dev Emitted when the admin account has changed.
    event AdminChanged(address indexed previousAdmin, address indexed newAdmin);

    /// @dev Emitted when the implementation is upgraded.
    event Upgraded(address indexed implementation);

    /// @dev Perform implementation upgrade
    /// Emits an {Upgraded} event.
    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    /// @dev Perform implementation upgrade with additional setup call.
    /// Emits an {Upgraded} event.
    function _upgradeToAndCall(
        address newImplementation,
        bytes memory data
    ) internal {
        _upgradeTo(newImplementation);
        if (data.length > 0) {
            newImplementation.functionDelegateCall(data);
        }
    }

    /// @notice Changes the admin of the proxy.
    /// @dev Emits an {AdminChanged} event.
    function _changeAdmin(address newAdmin) internal {
        _setAdmin(newAdmin);
        emit AdminChanged(_getAdmin(), newAdmin);
    }

    /// @dev Returns the current implementation address.
    function _getImplementation() internal view returns (address) {
        return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    /// @dev Returns the current admin.
    function _getAdmin() internal view returns (address) {
        return StorageSlot.getAddressSlot(_ADMIN_SLOT).value;
    }

    /// @dev Stores a new address in the EIP1967 admin slot.
    function _setAdmin(address newAdmin) private {
        if (newAdmin == address(0))
            revert ZeroAddressNotAllowed("ADMIN_ADDRESS");
        StorageSlot.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

    /// @dev Stores a new address in the EIP1967 implementation slot.
    function _setImplementation(address newImplementation) private {
        if (!newImplementation.hasContractCode())
            revert NotContractAddress(newImplementation);
        StorageSlot
            .getAddressSlot(_IMPLEMENTATION_SLOT)
            .value = newImplementation;
    }
}
