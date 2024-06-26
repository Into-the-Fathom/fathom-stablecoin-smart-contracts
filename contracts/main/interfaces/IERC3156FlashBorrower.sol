// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.17;

interface IERC3156FlashBorrower {
    /// @dev Receive a flash loan.
    /// @param _initiator The initiator of the loan.
    /// @param _token The loan currency.
    /// @param _amount The amount of tokens lent.
    /// @param _fee The additional amount of tokens to repay.
    /// @param _data Arbitrary data structure, intended to contain user-defined parameters.
    /// @return The keccak256 hash of "ERC3156FlashBorrower.onFlashLoan"
    function onFlashLoan(address _initiator, address _token, uint256 _amount, uint256 _fee, bytes calldata _data) external returns (bytes32);
}
