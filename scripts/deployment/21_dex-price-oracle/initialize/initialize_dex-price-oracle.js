const fs = require('fs');
// const rawdata = fs.readFileSync('../../../../addresses.json');
// let stablecoinAddress = JSON.parse(rawdata);

const DexPriceOracle = artifacts.require('./8.17/price-oracles/DexPriceOracle.sol');

  //goerli
  // const DEX_FACTORY_ADDR = "0xcaef5a76Caa3C7aCe06E5596b0a7c3d1e088c0fe" //

  //Apothem
  const DEX_FACTORY_ADDR = "0x69310bcBcC35b3d5C2b62C72E75dA68d58FDafC9" //

module.exports =  async function(deployer) {
  console.log(">> Initializing DexPriceOracle")

  const dexPriceOracle = await DexPriceOracle.at("0x16c5DA5b2535Dc8bE0b26B2584552a7423583967");


  await dexPriceOracle.initialize(
    DEX_FACTORY_ADDR
  )
};