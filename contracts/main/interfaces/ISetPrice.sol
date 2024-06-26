// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.17;

interface ISetPrice {
    function setPrice(bytes32 _collateralPoolId) external;
    function setPriceForBatch(bytes32[] calldata _collateralPoolIds) external;
}
