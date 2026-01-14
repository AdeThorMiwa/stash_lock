//SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.28;

import {SCSStorage} from "../libs/SCSStorage.sol";
import {CommonStorage} from "../libs/CommonStorage.sol";

import {ActionRejected} from "../utils/Errors.sol";
import {Context} from "./Context.sol";
import {UseOwner} from "../common/UseOwner.sol";

/// @title StashBase
/// @author AdeThorMiwa
/// @notice Abstract base contract providing core functionalities for stash contracts.
/// @dev This contract defines common modifiers for stash-related operations
///      It also inherits from `Context` and `UseOwner` for basic functionalities.
abstract contract StashBase is Context, UseOwner {

}
