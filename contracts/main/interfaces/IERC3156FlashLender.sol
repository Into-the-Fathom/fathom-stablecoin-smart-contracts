// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.17;

import "./IERC3156FlashBorrower.sol";

interface IERC3156FlashLender {
    /// @dev Initiate a flash loan.
    /// @param _receiver The receiver of the tokens in the loan, and the receiver of the callback.
    /// @param _token The loan currency.
    /// @param _amount The amount of tokens lent.
    /// @param _data Arbitrary data structure, intended to contain user-defined parameters.
    function flashLoan(IERC3156FlashBorrower _receiver, address _token, uint256 _amount, bytes calldata _data) external returns (bool);

    /// @dev The amount of currency available to be lent.
    /// @param _token The loan currency.
    /// @return The amount of `token` that can be borrowed.
    function maxFlashLoan(address _token) external view returns (uint256);

    /// @dev The fee to be charged for a given loan.
    /// @param _token The loan currency.
    /// @param _amount The amount of tokens lent.
    /// @return The amount of `token` to be charged for the loan, on top of the returned principal.
    function flashFee(address _token, uint256 _amount) external view returns (uint256);
}
