//SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.28;

/// @title CheckAddress Library
/// @author AdeThorMiwa
/// @notice Provides utility functions for address type, particularly to check if an address is a contract.
/// @dev This library contains a function to determine if an address has associated contract code.
library CheckAddress {
    /// @dev Checks if an address has associated contract code.
    /// @param _address The address to check for contract code.
    /// @return bool indicating whether the address has contract code.
    function hasContractCode(address _address) internal view returns (bool) {
        uint256 _codeSize;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            _codeSize := extcodesize(_address)
        }
        return _codeSize > 0;
    }
}
