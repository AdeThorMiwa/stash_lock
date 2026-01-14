//SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.28;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Types} from "../libs/Types.sol";

/// @title SCSStorage
/// @author AdeThorMiwa
/// @notice Library for managing storage and operations related to Smart Contract Stash (SCS)
/// @dev Contains functions for enforcing access control
library SCSStorage {
    /// @dev stash primary storage
    struct SPStorage {
        // Lookup address
        address lookupAddress;
        // list of tokens that has been deposited in this stash
        IERC20[] tokens;
        // status of the stash
        Types.StashStatus status;
        // balances of stash
        mapping(IERC20 => uint256) balances;
    }

    /// @dev Storage slot for SCS storage
    bytes32 internal constant SCS_STORAGE_SLOT =
        keccak256("com.stash.scs.storage");

    function _setStatus(Types.StashStatus status) internal {
        SPStorage storage sps = _store();
        sps.status = status;
    }

    /// @dev Return the contract's balance of the network coin
    /// @return balance The balance of the network coin
    function _balance() internal view returns (uint256) {
        return selfBalance();
    }

    /// @dev Return the contract's balance of a specific ERC20 token
    /// @param _token The ERC20 token address
    /// @return balance The balance of the token
    function _balance(IERC20 _token) internal view returns (uint256) {
        return _token.balanceOf(address(this));
    }

    function _status() internal view returns (Types.StashStatus) {
        return _store().status;
    }

    function _tokens() internal view returns (IERC20[] memory tokensList) {
        return _store().tokens;
    }

    /// @dev Use selfbalance instead of address(this).balance
    /// @return __balance The balance of the contract
    function selfBalance() internal view returns (uint256 __balance) {
        // solhint-disable-next-line no-inline-assembly
        assembly {
            __balance := selfbalance()
        }
    }

    /// @dev Returns storage from the defined slot
    /// @return sps The storage object
    function _store() internal pure returns (SPStorage storage sps) {
        bytes32 pos = SCS_STORAGE_SLOT;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            sps.slot := pos
        }
    }
}
