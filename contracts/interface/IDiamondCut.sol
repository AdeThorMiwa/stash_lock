// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import {Types} from "../libs/Types.sol";

/// @title IDiamondCut
/// @author AdeThorMiwa
/// @notice Interface for the DiamondCut operation.
/// @dev Defines the functions for adding, replacing, or removing facets in a diamond contract.
interface IDiamondCut {
    /// @dev Emitted when a diamond cut operation is executed.
    /// @param _diamondCut An array of facet cut actions.
    /// @param _init The address of the initialization contract (if any).
    /// @param _calldata The calldata for the initialization call (if any).
    event DiamondCut(
        Types.FacetCut[] _diamondCut,
        address indexed _init,
        bytes _calldata
    );

    /// @dev Adds, replaces, or removes facets in a diamond contract.
    /// @param _diamondCut An array of facet cut actions.
    function diamondCut(Types.FacetCut[] calldata _diamondCut) external;

    /// @dev Adds, replaces, or removes facets in a diamond contract and executes an initialization call.
    /// @param _diamondCut An array of facet cut actions.
    /// @param _initTarget The address of the initialization contract.
    /// @param _initCalldata The calldata for the initialization call.
    function diamondCut(
        Types.FacetCut[] calldata _diamondCut,
        address _initTarget,
        bytes calldata _initCalldata
    ) external;
}
