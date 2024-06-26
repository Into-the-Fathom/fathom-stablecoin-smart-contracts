// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.17;

import "../interfaces/IStablecoinAdapter.sol";

interface IStablecoinAdapterGetter {
    function stablecoinAdapter() external returns (IStablecoinAdapter);
}
