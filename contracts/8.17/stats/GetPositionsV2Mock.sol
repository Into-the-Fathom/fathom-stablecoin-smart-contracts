// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.17;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "../managers/PositionManager.sol";
import "../interfaces/IBookKeeper.sol";
import "../interfaces/ICollateralPoolConfig.sol";
//added 2022 Sep 28th,  05:02 pm
import "./interfaces/IFathomStats.sol";


contract GetPositionsV2Mock is Initializable {
  using SafeMathUpgradeable for uint256;

  // --- Math ---
  uint256 constant WAD = 10**18;
  uint256 constant RAY = 10**27;
  uint256 constant RAD = 10**45;


  function getAllPositionsAsc(address _manager, address _user)
    external
    view
    returns (
      uint256[] memory _ids,
      address[] memory _positions,
      bytes32[] memory _collateralPools
    )
  {
    uint256 _count = PositionManager(_manager).ownerPositionCount(_user);
    uint256 _id = PositionManager(_manager).ownerFirstPositionId(_user);
    return _getPositionsAsc(_manager, _id, _count);
  }

  function getPositionsAsc(
    address _manager,
    uint256 _fromId,
    uint256 _size
  )
    external
    view
    returns (
      uint256[] memory _ids,
      address[] memory _positions,
      bytes32[] memory _collateralPools
    )
  {
    return _getPositionsAsc(_manager, _fromId, _size);
  }

  function _getPositionsAsc(
    address _manager,
    uint256 _fromId,
    uint256 _size
  )
    internal
    view
    returns (
      uint256[] memory _ids,
      address[] memory _positions,
      bytes32[] memory _collateralPools
    )
  {
    _ids = new uint256[](_size);
    _positions = new address[](_size);
    _collateralPools = new bytes32[](_size);
    uint256 _i = 0;
    uint256 _id = _fromId;

    while (_id > 0 && _i < _size) {
      _ids[_i] = _id;
      _positions[_i] = PositionManager(_manager).positions(_id);
      _collateralPools[_i] = PositionManager(_manager).collateralPools(_id);
      (, _id) = PositionManager(_manager).list(_id);
      _i++;
    }
  }

  function getAllPositionsDesc(address _manager, address _user)
    external
    view
    returns (
      uint256[] memory,
      address[] memory,
      bytes32[] memory
    )
  {
    uint256 _count = PositionManager(_manager).ownerPositionCount(_user);
    uint256 _id = PositionManager(_manager).ownerLastPositionId(_user);
    return _getPositionsDesc(_manager, _id, _count);
  }

  function getPositionsDesc(
    address _manager,
    uint256 _fromId,
    uint256 _size
  )
    external
    view
    returns (
      uint256[] memory,
      address[] memory,
      bytes32[] memory
    )
  {
    return _getPositionsDesc(_manager, _fromId, _size);
  }

  function _getPositionsDesc(
    address _manager,
    uint256 _fromId,
    uint256 _size
  )
    internal
    view
    returns (
      uint256[] memory _ids,
      address[] memory _positions,
      bytes32[] memory _collateralPools
    )
  {
    _ids = new uint256[](_size);
    _positions = new address[](_size);
    _collateralPools = new bytes32[](_size);
    uint256 _i = 0;
    uint256 _id = _fromId;

    while (_id > 0 && _i < _size) {
      _ids[_i] = _id;
      _positions[_i] = PositionManager(_manager).positions(_id);
      _collateralPools[_i] = PositionManager(_manager).collateralPools(_id);
      (_id, ) = PositionManager(_manager).list(_id);
      _i++;
    }
  }

  function getPositionWithSafetyBuffer(
    address _manager,
    uint256 _startIndex,
    uint256 _offset
  )
    external
    view
    returns (
      address[] memory _positions,
      uint256[] memory _debtShares,
      // uint256[] memory _safetyBuffers,
      uint256[] memory _lockedCollaterals,
      uint256[] memory _lockedValues,
      uint256[] memory _positionLTVs
      // uint256[] memory _colPrices,
      // uint256[] memory _liquidationPrices
    )
  {
    if (_startIndex.add(_offset) > PositionManager(_manager).lastPositionId())
      _offset = PositionManager(_manager).lastPositionId().sub(_startIndex).add(1);

    IBookKeeper _bookKeeper = IBookKeeper(PositionManager(_manager).bookKeeper());
    _positions = new address[](_offset);
    _debtShares = new uint256[](_offset);
    // _safetyBuffers = new uint256[](_offset);

    //2022 Sep 28th Wed 4:56 PM added
    _lockedCollaterals = new uint256[](_offset);
    _lockedValues = new uint256[](_offset);
    _positionLTVs = new uint256[](_offset);
    // _colPrices = new uint256[](_offset);
    // _liquidationPrices = new uint256[](_offset);
    uint256 _resultIndex = 0;
    for (uint256 _positionIndex = _startIndex; _positionIndex < _startIndex.add(_offset); _positionIndex++) {
      if (PositionManager(_manager).positions(_positionIndex) == address(0)) break;
      _positions[_resultIndex] = PositionManager(_manager).positions(_positionIndex);

      // bytes32 _collateralPoolId = PositionManager(_manager).collateralPools(_positionIndex);
      // (uint256 _lockedCollateral, uint256 _debtShare) = _bookKeeper.positions(
      //   _collateralPoolId,
      //   _positions[_resultIndex]
      // );
      //2022 Sep 28th Wed 4:57 PM added
      // _lockedCollaterals[_resultIndex] = _lockedCollateral;
            _lockedCollaterals[_resultIndex] = 0;

      // uint256 _colPrice;
      //PriceFetch from DexPriceOracle
      // if (_collateralPoolId == 0x5758444300000000000000000000000000000000000000000000000000000000) {
      //   _colPrice = 100000000000000000000;
      // } else if (_collateralPoolId == 0x4654484d00000000000000000000000000000000000000000000000000000000) {
      //   _colPrice = 1000000000000000000;
      // } else {
      //   _colPrice = 1000000000000000000;
      // }
      // _colPrices[_resultIndex] = _colPrice;
      //calculate LockedValue
      _lockedValues[_resultIndex] = 0;
      // _lockedValues[_resultIndex] = _lockedCollateral * _colPrice / WAD;

      // we assume FXD is 1 dollar. 
      // if ( _lockedValues[_resultIndex] != 0){
      //   _positionLTVs[_resultIndex] = (_debtShare * 1000 / _lockedValues[_resultIndex]);
      // } else {
      //   _positionLTVs[_resultIndex] = 0;
      // }
      // ICollateralPoolConfig collateralPoolConfig = ICollateralPoolConfig(_bookKeeper.collateralPoolConfig());
        _positionLTVs[_resultIndex] = 0;

      // uint256 _safetyBuffer = calculateSafetyBuffer(
      //   _debtShare,
      //   collateralPoolConfig.getDebtAccumulatedRate(_collateralPoolId),
      //   _lockedCollateral,
      //   collateralPoolConfig.getPriceWithSafetyMargin(_collateralPoolId)
        // _colPrice
      // );
      // _liquidationPrices[_resultIndex] = _liquidationPrice;
      // _safetyBuffers[_resultIndex] = _safetyBuffer;
      // _debtShares[_resultIndex] = _debtShare;
            _debtShares[_resultIndex] = 0;

      _resultIndex++;
    }
  }



  function calculateSafetyBuffer(
    uint256 _debtShare, // [wad]
    uint256 _debtAccumulatedRate, // [ray]
    uint256 _lockedCollateral, // [wad]
    uint256 _priceWithSafetyMargin // [ray]
    // uint256 _colPrice // [wad]
  )
    internal
    pure
    returns (
      uint256 _safetyBuffer // [rad]
      // uint256 _liquidationPrice // [ray]
    )
  {
    uint256 _collateralValue = _lockedCollateral.mul(_priceWithSafetyMargin);
    uint256 _debtValue = _debtShare.mul(_debtAccumulatedRate);
    _safetyBuffer = _collateralValue >= _debtValue ? _collateralValue.sub(_debtValue) : 0;
    // _liquidationPrice = _colPrice - (_safetyBuffer / _lockedCollateral);
    // if(_safetyBuffer == 0) {
    //   _liquidationPrice = 0;
    // }
    // if(_colPrice * RAY < (_safetyBuffer / _lockedCollateral)) {
    //   _liquidationPrice = 0;
    // } else {
    //   _liquidationPrice = _colPrice - (_safetyBuffer / _lockedCollateral);
    // }
  }
}
