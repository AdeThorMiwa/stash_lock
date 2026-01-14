//SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.28;

import {CheckAddress} from "../libs/CheckAddress.sol";

import {InvalidLookupImplementation} from "../utils/Errors.sol";

/// @title UseLookup
/// @author AdeThorMiwa
/// @notice Abstract base contract for lookup-based function delegation.
/// @dev This contract enables delegating function calls to dynamically deployed
///      implementation contracts based on function signatures. It acts as a
///      lookup proxy and utilizes a separate contract {LookupOps}
///      to manage the mapping between function signatures and implementation
///
abstract contract UseLookup {
    using CheckAddress for address;

    /// @dev Event emitted when a deposit is received to the contract.
    /// @param stash The address of the related stash contract (if applicable).
    /// @param from The address of the sender.
    /// @param value The amount of the deposit.
    event DepositReceived(
        address indexed stash,
        address indexed from,
        uint256 value
    );

    /// @notice Function to receive ether sent directly to the contract.
    /// @dev Emits a `DepositReceived` event for tracking.
    // solhint-disable-next-line no-empty-blocks
    receive() external payable virtual {
        emit DepositReceived(address(this), msg.sender, msg.value);
    }

    /// @notice Fallback function to handle calls to non-existent functions.
    /// @dev This function delegates the call to the appropriate implementation contract
    ///      based on the function signature using the `_delegate` function.
    fallback() external payable virtual {
        _delegate();
    }

    /// @dev Internal function to delegate a function call based on the message signature.
    function _delegate() internal {
        address implementation = _implementation(msg.sig);

        if (!implementation.hasContractCode()) {
            revert InvalidLookupImplementation(implementation, msg.sig);
        }

        // solhint-disable-next-line no-inline-assembly
        assembly {
            // Copy msg.data
            calldatacopy(0, 0, calldatasize())

            // Call the implementation.
            let result := delegatecall(
                gas(),
                implementation,
                0,
                calldatasize(),
                0,
                0
            )

            // Copy the returned data.
            returndatacopy(0, 0, returndatasize())

            // check returned result
            switch result
            // delegate call returns 0 on error
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    /// @notice Abstract function to retrieve the implementation address for a function signature.
    /// @dev This function should be implemented in the inheriting contract to define the
    ///      logic for retrieving the implementation address based on the function signature.
    ///      It should return the address of the implementation contract or the zero address
    ///      if no implementation is found.
    /// @param _signature The function signature (4 bytes).
    /// @return implementation The address of the implementation contract.
    function _implementation(
        bytes4 _signature
    ) internal view virtual returns (address implementation);
}
