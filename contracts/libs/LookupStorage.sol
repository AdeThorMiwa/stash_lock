// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.28;

import {Types} from "../libs/Types.sol";
import {CheckAddress} from "../libs/CheckAddress.sol";

import {Address} from "@openzeppelin/contracts/utils/Address.sol";

import {ImmutableImplementationReplacementError, NotContractAddress, EmptyInitCallData} from "../utils/Errors.sol";
import {FacetSelectorExists, InvalidFacetFunction, InvalidFuncSelectorsCount} from "../utils/Errors.sol";
import {InvalidFacetContract, ImmutableFunctionReplacementError} from "../utils/Errors.sol";

/// @title LookupStorage Library
/// @author AdeThorMiwa
/// @notice Library for managing storage and function selectors for a diamond facet implementation.
/// @dev This library includes functionality for handling diamond cuts, retrieving and setting lock states,
///      and managing function selectors and implementations.
library LookupStorage {
    using Address for address;
    using CheckAddress for address;

    /// @dev Implementation address and selector position
    struct ImpleAddrAndSelectorPos {
        // Address of the facet
        address facetAddress;
        // Position of the selector in the selectors array
        uint16 selectorPosition;
    }

    /// @dev Structure representing the lookup storage used in the contract
    struct LStorage {
        // Array of function selectors
        bytes4[] selectors;
        // Mapping to track lock state of implementations
        mapping(address => bool) lockState;
        // Mapping to track global implementation state
        mapping(address => bool) globalImplementation;
        // Mapping to track implementation lock keys
        mapping(address => bytes8) implementationLock;
        // Mapping to track implementation address and selector position
        mapping(bytes4 => ImpleAddrAndSelectorPos) impleAddrAndSelectorPos;
    }

    /// @dev Random storage slot
    bytes32 internal constant LOOKUP_STORAGE_SLOT =
        keccak256("com.stash.lookup.storage");

    /// @notice Add/Replace functions
    /// @dev Gas estimate values in function are conservative value not absolute values
    /// @param _diamondCut Array of diamond facet cut operations
    function _handleDiamondCut(Types.FacetCut[] memory _diamondCut) internal {
        for (uint256 i = 0; i < _diamondCut.length; i++) {
            Types.FacetCut memory facetCut = _diamondCut[i];

            address _facetAddress = _diamondCut[i].facetAddress;

            bytes4[] memory _functionSelectors = _diamondCut[i]
                .functionSelector;

            if (!_facetAddress.hasContractCode())
                revert InvalidFacetContract(_facetAddress);

            if (_functionSelectors.length == 0)
                revert InvalidFuncSelectorsCount(_functionSelectors.length);

            if (facetCut.action == Types.FacetCutAction.ADD) {
                _addFunctions(_facetAddress, _functionSelectors);
            } else if (facetCut.action == Types.FacetCutAction.REPLACE) {
                _replaceFunctions(_facetAddress, _functionSelectors);
            } else if (facetCut.action == Types.FacetCutAction.REMOVE) {
                _removeFunctions(_functionSelectors);
            }
        }
    }

    /// @dev Enable or disable implementation lock state
    /// @param _implementation Address of the implementation
    /// @param _lockState New lock state to be set
    function _setLockState(address _implementation, bool _lockState) internal {
        _store().lockState[_implementation] = _lockState;
    }

    /// @dev Handle DiamondCut Add functions operations
    /// @param _facetAddress Facet address
    /// @param _functionSelectors Array of function selector signatures to add
    function _addFunctions(
        address _facetAddress,
        bytes4[] memory _functionSelectors
    ) internal {
        LStorage storage ls = _store();

        uint16 _selectorsCount = uint16(ls.selectors.length);

        for (uint256 i = 0; i < _functionSelectors.length; i++) {
            /// @dev indexSelector
            bytes4 _selector = _functionSelectors[i];
            /// @dev existng facet implementation at selector psosition
            address _oldImplementation = ls
                .impleAddrAndSelectorPos[_selector]
                .facetAddress;

            /// @dev Avoid implementation override
            if (_oldImplementation.hasContractCode())
                revert FacetSelectorExists(_oldImplementation, _selector);

            /// @dev Add function
            ls.impleAddrAndSelectorPos[_selector] = ImpleAddrAndSelectorPos(
                _facetAddress,
                _selectorsCount
            );

            ls.selectors.push();
            ls.selectors[_selectorsCount] = _selector;
            _selectorsCount++;
        }
    }

    /// @dev Handle DiamondCut Replace functions
    /// @param _facetAddress Facet address
    /// @param _functionSelectors Array of function selector signatures to replace
    function _replaceFunctions(
        address _facetAddress,
        bytes4[] memory _functionSelectors
    ) internal {
        LStorage storage ls = _store();

        for (uint256 i = 0; i < _functionSelectors.length; i++) {
            bytes4 _selector = _functionSelectors[i];
            address _oldImplementation = ls
                .impleAddrAndSelectorPos[_selector]
                .facetAddress;

            if (_oldImplementation == address(this))
                revert ImmutableFunctionReplacementError(
                    _oldImplementation,
                    _selector
                );

            if (_oldImplementation == _facetAddress)
                revert ImmutableImplementationReplacementError(
                    _oldImplementation,
                    _selector
                );

            if (_oldImplementation == address(0))
                revert InvalidFacetContract(_oldImplementation);

            ls.impleAddrAndSelectorPos[_selector].facetAddress = _facetAddress;
        }
    }

    /// @dev Handle DiamondCut Remove functions
    /// @param _functionSelectors Array of  function selector signatures to replace
    function _removeFunctions(bytes4[] memory _functionSelectors) internal {
        LStorage storage ls = _store();

        uint256 curSelectorsCount = ls.selectors.length;

        for (uint256 i = 0; i < _functionSelectors.length; i++) {
            bytes4 selector = _functionSelectors[i];

            ImpleAddrAndSelectorPos memory oldAddressAndPos = ls
                .impleAddrAndSelectorPos[selector];

            if (oldAddressAndPos.facetAddress == address(0))
                revert InvalidFacetFunction(
                    oldAddressAndPos.facetAddress,
                    selector
                );

            if (oldAddressAndPos.facetAddress == address(this))
                revert ImmutableImplementationReplacementError(
                    oldAddressAndPos.facetAddress,
                    selector
                );

            curSelectorsCount--;

            if (oldAddressAndPos.selectorPosition != curSelectorsCount) {
                bytes4 lastSelector = ls.selectors[curSelectorsCount];
                ls.selectors[oldAddressAndPos.selectorPosition] = lastSelector;
                ls
                    .impleAddrAndSelectorPos[lastSelector]
                    .selectorPosition = oldAddressAndPos.selectorPosition;
            }

            ls.selectors.pop();

            delete ls.impleAddrAndSelectorPos[selector];
        }
    }

    /// @dev Handle post-facet registration calls
    /// @param _targetAddress Address of the target contract
    /// @param _initCallData Initialization call data
    function _handleInitCall(
        address _targetAddress,
        bytes memory _initCallData
    ) internal {
        if (_targetAddress != address(this)) {
            if (!_targetAddress.hasContractCode())
                revert NotContractAddress(_targetAddress);
        }

        if (_initCallData.length == 0) revert EmptyInitCallData();

        _targetAddress.functionDelegateCall(_initCallData);
    }

    /// @dev Set implementation lock key
    /// @param _implementation Address of the implementation
    /// @param _lockKey New lock key to be set
    function _setLockKey(address _implementation, bytes8 _lockKey) internal {
        _store().implementationLock[_implementation] = _lockKey;
    }

    /// @dev Enable or disable global implementation state
    /// @param _implementation Address of the implementation
    /// @param _gState New global state to be set
    function _setGlobalState(address _implementation, bool _gState) internal {
        _store().globalImplementation[_implementation] = _gState;
    }

    /// @dev Get implementation address using call signature
    /// @param _signature Call signature
    /// @return implementation Call signature facet implementation
    function _signatureImplementation(
        bytes4 _signature
    ) internal view returns (address implementation) {
        LookupStorage.LStorage storage ls = _store();
        implementation = address(
            bytes20(ls.impleAddrAndSelectorPos[_signature].facetAddress)
        );
    }

    /// @dev Get implementation lock state
    /// @param _implementation Address of the implementation
    /// @return lockState Lock state of the implementation
    function _getLockState(
        address _implementation
    ) internal view returns (bool lockState) {
        lockState = _store().lockState[_implementation];
    }

    /// @dev Get implementation lock key
    /// @param _implementation Address of the implementation
    /// @return lockKey Lock key of the implementation
    function _getLockKey(
        address _implementation
    ) internal view returns (bytes8 lockKey) {
        lockKey = _store().implementationLock[_implementation];
    }

    /// @dev Is implementation global
    /// @param _implementation Address of the implementation
    /// @return gImplState Global implementation state
    function _getGlobalState(
        address _implementation
    ) internal view returns (bool gImplState) {
        gImplState = _store().globalImplementation[_implementation];
    }

    /// @dev Get object from storage slot
    /// @return ls Lookup Storage object
    function _store() internal pure returns (LStorage storage ls) {
        bytes32 pos = LOOKUP_STORAGE_SLOT;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            ls.slot := pos
        }
    }
}
