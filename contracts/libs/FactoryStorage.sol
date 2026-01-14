//SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.28;

/// @title FactoryStorage Library
/// @author AdeThorMiwa
/// @notice Provides a storage structure and utility functions for managing factory-related storage data.
/// @dev This library contains functions for managing stash and user account limits.
library FactoryStorage {
    /// @dev Factory storage structure.
    struct FStorage {
        // The maximum number of stash allowed to be created by a single user.
        uint16 userMaxStash;
        // Mapping indicating whether an address is a stash.
        mapping(address => bool) isStash;
        // Mapping of user addresses to their stashes.
        mapping(address => address[]) stashes;
    }

    /// @dev Random storage slot for factory storage.
    bytes32 internal constant FACTORY_STORAGE_SLOT =
        keccak256("com.stash.factory.storage");

    /// @dev Sets the allowed maximum number of user stash.
    /// @param _limit The maximum user stash limit.
    function _setUserMaxStash(uint16 _limit) internal {
        FStorage storage fs = _store();
        fs.userMaxStash = _limit;
    }

    /// @dev Adds a stash for an owner.
    /// @param _owner The owner's address.
    /// @param _stashAddress The stash address.
    /// @param _stashIndex The index of the stash.
    function _addStash(
        address _owner,
        address _stashAddress,
        uint256 _stashIndex
    ) internal {
        FStorage storage fs = _store();
        fs.stashes[_owner].push();
        fs.stashes[_owner][_stashIndex] = _stashAddress;
        fs.isStash[_stashAddress] = true;
    }

    /// @dev Checks if an address is a registered stash.
    /// @param _stash The address to check.
    /// @return True if the address is a registered stash, false otherwise.
    function _isStash(address _stash) internal view returns (bool) {
        return _store().isStash[_stash];
    }

    /// @dev Gets the allowed maximum number of user stash.
    /// @return maxStash The allowed maximum number of user stash.
    function _getUserStashLimit() internal view returns (uint16 maxStash) {
        maxStash = _store().userMaxStash;
    }

    /// @dev Gets the stash associated with a owner.
    /// @param _ownerAddress The owner's address.
    /// @return stashes The list of stash accounts.
    /// @return currentCount The current number of stash accounts.
    function _getStashes(
        address _ownerAddress
    ) internal view returns (address[] memory stashes, uint256 currentCount) {
        stashes = _store().stashes[_ownerAddress];
        currentCount = stashes.length;
    }

    /// @dev Returns storage value from designated slot.
    /// @return fs The factory storage structure.
    function _store() internal pure returns (FStorage storage fs) {
        bytes32 pos = FACTORY_STORAGE_SLOT;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            fs.slot := pos
        }
    }
}
