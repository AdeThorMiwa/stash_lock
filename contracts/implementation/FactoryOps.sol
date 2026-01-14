//SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.28;

import {IFactory} from "../interface/IFactory.sol";

import {CommonStorage} from "../libs/CommonStorage.sol";
import {FactoryStorage} from "../libs/FactoryStorage.sol";
import {StashLimitReached, ZeroAddressNotAllowed, ActionRejected} from "../utils/Errors.sol";
import {Ownable} from "../common/Ownable.sol";
import {Stash} from "../Stash.sol";

/// @title FactoryOps Contract
/// @author AdeThorMiwa
/// @notice This contract handles operations for managing stashs within a factory.
/// @dev Handles stash contract creation and registration
contract FactoryOps is Ownable, IFactory {
    /// @notice Creates a new stash for the message sender.
    function createStash() external override {
        _createStash(_msgSender());
    }

    /// @dev Creates a new stash for a specific owner.
    /// @param _ownerAddress The address of the owner.
    /// @dev Only the owner can call this function.
    function createStash(address _ownerAddress) external override onlyOwner {
        if (_ownerAddress == address(0))
            revert ZeroAddressNotAllowed("OWNER_ADDRESS");
        _createStash(_ownerAddress);
    }

    /// @dev Checks if a given address is a stash.
    /// @param _stash The address to check.
    /// @return True if the address is a stash, false otherwise.
    function isStash(address _stash) external view returns (bool) {
        return FactoryStorage._isStash(_stash);
    }

    /// @notice Checks if the contract supports a specific interface.
    /// @param _interfaceId The interface identifier to check.
    /// @return bool True if the interface is supported, false otherwise.
    function supportsInterface(
        bytes4 _interfaceId
    ) external view override returns (bool) {
        return CommonStorage._getSupportedInterface(_interfaceId);
    }

    /// @notice Gets the current lookup proxy address for the factory.
    /// @return address The address of the current lookup proxy.
    function getLookupProxy() external view override returns (address) {
        return CommonStorage._getLookupProxy();
    }

    /// @dev Returns an array of stash owned by a given address.
    /// @param _ownerAddress The address of the stash owner.
    /// @return stashes An array of stash addresses.
    /// @return currentCount The number of stash owned by the address.
    function getStashes(
        address _ownerAddress
    ) external view returns (address[] memory stashes, uint256 currentCount) {
        return FactoryStorage._getStashes(_ownerAddress);
    }

    /// @dev Internal function to create a stash using CREATE2.
    /// @param _ownerAddress The third-party address to create the stash account for.
    function _createStash(address _ownerAddress) internal {
        address stash;
        uint256 stashIndex;

        address lookupProxy = CommonStorage._getLookupProxy();

        uint16 maxStash = FactoryStorage._getUserStashLimit();

        (, stashIndex) = FactoryStorage._getStashes(_ownerAddress);

        // Check account serial limit
        if (stashIndex >= maxStash) {
            revert StashLimitReached(_ownerAddress, maxStash);
        }

        // Hash owner address and serial to get unique salt
        bytes32 salt = keccak256(abi.encodePacked(_ownerAddress, stashIndex));

        // This will generate a Stash Contract using CREATE2
        // solhint-disable-next-line no-inline-assembly
        bytes memory _bytecode = abi.encodePacked(
            type(Stash).creationCode,
            abi.encode(_ownerAddress, address(this), lookupProxy)
        );

        // solhint-disable-next-line no-inline-assembly
        assembly {
            stash := create2(0, add(_bytecode, 32), mload(_bytecode), salt)
        }

        // Add Savings Account
        FactoryStorage._addStash(_ownerAddress, stash, stashIndex);

        emit StashCreated(_ownerAddress, stash, stashIndex);
    }

    /// @dev Overrides the ownership transfer implementation to use the implemented storage.
    /// @param _newOwner The address of the new owner.
    function _transferOwnership(address _newOwner) internal override {
        CommonStorage._setOwner(_newOwner);
    }

    /// @dev Overrides the get owner implementation to use the implemented storage.
    /// @return address The address of the current owner.
    function _getOwner() internal view override returns (address) {
        return CommonStorage._getOwner();
    }
}
