//SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.28;

import {ILookup, IERC165, IERC173} from "./interface/ILookup.sol";

import {CommonStorage} from "./libs/CommonStorage.sol";

import {UseLookup} from "./common/UseLookup.sol";

/// @title Stash Contract
/// @author AdeThorMiwa
/// @notice This contract handles the stash account functionality including setup and lookup implementations.
/// @dev The contract is created using CREATE2 to ensure consistent stash addresses across EVM chains.
contract Stash is UseLookup {
    /// @notice This key is used to lock implementations to Stash contract
    /// @dev This is calculated thus: bytes8(keccak256(abi.encodePacked("Stash")))
    bytes8 public constant IMPL_KEY = 0x1a76ecadaefb8d4f;

    /// @notice constructs stash contract
    /// @dev contract is created using CREATE2 to ensure some sort of stash address consistently across evm chains for owner
    /// @param factory stash factory address
    /// @param owner stash contract owner address
    /// @param lookupProxy implementation lookup proxy address
    constructor(address owner, address factory, address lookupProxy) {
        CommonStorage._setOwner(owner);
        CommonStorage._setFactory(factory);
        CommonStorage._setLookupProxy(lookupProxy);

        // Setup supported interfaces
        CommonStorage._setSupportedInterface(type(IERC165).interfaceId, true);
        CommonStorage._setSupportedInterface(type(IERC173).interfaceId, true);
    }

    /// @inheritdoc	UseLookup
    function _implementation(
        bytes4 _signature
    ) internal view override returns (address implementation) {
        address lookupProxyAddress = CommonStorage._getLookupProxy();
        implementation = ILookup(lookupProxyAddress).getImplementation(
            _signature,
            IMPL_KEY
        );
    }
}
