//SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.28;

/// @title StorageSlot Library
/// @author AdeThorMiwa
/// @notice Library for managing value storage slots
/// @dev Provides functions to work with specific storage slots. Useful for reading and writing to contract storage slots directly.
// solhint-disable no-inline-assembly
library StorageSlot {
    /// @dev Struct to represent an address storage slot.
    struct AddressSlot {
        // The address value stored at the slot.
        address value;
    }

    /// @notice Returns an `AddressSlot` with member `value` located at `slot`.
    /// @param slot The storage slot to read from.
    /// @return r The `AddressSlot` with the value located at `slot`.
    function getAddressSlot(
        bytes32 slot
    ) internal pure returns (AddressSlot storage r) {
        assembly {
            r.slot := slot
        }
    }
}
