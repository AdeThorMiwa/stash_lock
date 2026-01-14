//SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.28;

/// @title CheckCallResult Library
/// @author AdeThorMiwa
/// @notice Provides a utility function to verify the result of a low-level call and revert if it fails.
/// @dev This library contains a function to verify the success of a low-level call and handle the returned data or revert with an error message.
library CheckCallResult {
    /// @dev Verifies the result of a low-level call.
    /// @param _success A boolean indicating the success of the call.
    /// @param _returnData The data returned from the call.
    /// @param _errMessage The error message to revert with if the call failed and no return data is provided.
    /// @return bytes The data returned from the call if it was successful.
    function verifyCallResult(
        bool _success,
        bytes memory _returnData,
        string memory _errMessage
    ) internal pure returns (bytes memory) {
        if (_success) {
            return _returnData;
        } else {
            if (_returnData.length > 0) {
                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returnDataSize := mload(_returnData)
                    revert(add(32, _returnData), returnDataSize)
                }
            } else {
                revert(_errMessage);
            }
        }
    }
}
