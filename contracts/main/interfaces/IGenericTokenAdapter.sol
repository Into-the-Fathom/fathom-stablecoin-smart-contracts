// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.17;

import "../interfaces/IToken.sol";

interface IGenericTokenAdapter {
    function decimals() external returns (uint256);

    function deposit(address positionAddress, uint256 wad, bytes calldata data) external payable;

    function withdraw(address positionAddress, uint256 wad, bytes calldata data) external;

    function collateralToken() external returns (address);

    function collateralPoolId() external view returns (bytes32);
}
