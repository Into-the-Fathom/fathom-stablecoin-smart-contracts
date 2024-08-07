// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.17;

interface IWNATIVE {
    function deposit() external payable;

    function withdraw(uint256) external;
}
