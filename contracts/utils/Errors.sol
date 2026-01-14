//SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

/// @title Custom Errors for Smart Contract
/// @author AdeThorMiwa
/// @dev This contract defines custom errors used throughout the system to provide detailed revert reasons.

/// @notice Emitted when an account is unauthorized.
/// @param account The unauthorized account address.
/// @param message The error message.
error UnauthorizedAccount(address account, string message);

/// @notice Emitted when a zero address is not allowed.
/// @param message The error message.
error ZeroAddressNotAllowed(string message);

/// @notice Emitted when a target address is not a contract.
/// @param target The target address.
error NotContractAddress(address target);

/// @notice Emitted when an action is rejected.
/// @param action The action that was rejected.
error ActionRejected(string action);

/// @notice Emitted when input data is invalid.
/// @param input The invalid input.
/// @param message The error message.
error InvalidInputData(string input, string message);

/// @notice Emitted when the stash limit is reached.
/// @param owner The account owner address.
/// @param limit The limit reached.
error StashLimitReached(address owner, uint16 limit);

/// @notice Emitted when a lookup implementation is invalid.
/// @param implementation The implementation address.
/// @param signature The function signature.
error InvalidLookupImplementation(address implementation, bytes4 signature);

/// @notice Emitted when attempting to replace an immutable implementation.
/// @param facet The facet address.
/// @param selector The function selector.
error ImmutableImplementationReplacementError(address facet, bytes4 selector);

/// @notice Emitted when the initialization call data is empty.
error EmptyInitCallData();

/// @notice Emitted when a facet selector already exists.
/// @param facet The facet address.
/// @param selector The function selector.
error FacetSelectorExists(address facet, bytes4 selector);

/// @notice Emitted when a facet function is invalid.
/// @param facet The facet address.
/// @param selector The function selector.
error InvalidFacetFunction(address facet, bytes4 selector);

/// @notice Emitted when the count of function selectors is invalid.
/// @param count The count of function selectors.
error InvalidFuncSelectorsCount(uint256 count);

/// @notice Emitted when a facet contract is invalid.
/// @param contractAddress The invalid facet contract address.
error InvalidFacetContract(address contractAddress);

/// @notice Emitted when attempting to replace an immutable function.
/// @param facet The facet address.
/// @param selector The function selector.
error ImmutableFunctionReplacementError(address facet, bytes4 selector);

/// @notice Emitted when an implementation lock key is invalid.
/// @param key The invalid lock key.
error InvalidImplementationLockKey(bytes8 key);

/// @notice Emitted when there is not enough balance for a transfer.
/// @param account The account initiating the transfer.
/// @param recipient The recipient of the transfer.
/// @param balance The current balance of the account.
/// @param amount The amount to be transferred.
/// @param token The address of the token contract.
error NotEnoughBalance(
    address account,
    address recipient,
    uint256 balance,
    uint256 amount,
    address token
);

/// @notice Emitted when the message value is invalid.
/// @param message The error message.
error InvalidMessageValue(string message);

/// @notice Emitted when a token contract address is invalid.
/// @param token The invalid token contract address.
error InvalidTokenContractAddress(address token);

/// @notice Emitted when the withdrawal recipient is invalid.
/// @param recipient The recipient address.
error InvalidWithdrawalRecipient(address recipient);

/// @notice Emitted when an operation amount is invalid
error InvalidOperationAmount(string message, uint256 amount);
