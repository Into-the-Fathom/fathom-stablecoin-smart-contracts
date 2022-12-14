const fs = require('fs');
const rawdata = fs.readFileSync('../../../../addresses.json');
let stablecoinAddress = JSON.parse(rawdata);

const PositionManager = artifacts.require('./main/managers/PositionManager.sol');

module.exports =  async function(deployer) {
  console.log(">> Initializing positionManager")

  const positionManager = await PositionManager.at(stablecoinAddress.positionManager);

  await positionManager.setPriceOracle(
    stablecoinAddress.priceOracle,
  );

};