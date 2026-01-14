//SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.28;

import {IERC165} from "./IERC165.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {Types} from "../libs/Types.sol";

/// @title IStashOps
/// @author AdeThorMiwa
/// @notice Interface for stash account operations.
/// @dev Defines functions for managing stash accounts, including
///     managing, and querying stash information.
interface IStashOps is IERC165 {
    event StashStatusChanged(address indexed stash, Types.StashStatus status);

    function balance() external view returns (uint256);

    function balance(IERC20 token) external view returns (uint256);

    function tokens() external view returns (IERC20[] memory);

    function setStatus(Types.StashStatus _status) external;

    function status() external view returns (Types.StashStatus status);
}
