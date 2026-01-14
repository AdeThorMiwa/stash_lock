// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.28;

/// @title Types Library
/// @author AdeThorMiwa
/// @notice Library to hold re-usable custom types
/// @dev Declare re-usable enums and structs
library Types {
    /// @dev Enum to represent the type of action to be taken on a facet cut.
    enum FacetCutAction {
        ADD, // 0: Add a new facet.
        REPLACE, // 1: Replace an existing facet.
        REMOVE // 2: Remove a facet.
    }

    /// @dev Struct to represent a cut on a facet.
    struct FacetCut {
        //The address of the facet.
        address facetAddress;
        // The action to be taken on the facet.
        FacetCutAction action;
        // The list of function selectors for the facet.
        bytes4[] functionSelector;
    }

    /// @dev Struct to represent client arguments.
    struct ClientArgs {
        // The address of the client.
        address client;
    }

    enum StashStatus {
        OPEN,
        CLOSED
    }
}
