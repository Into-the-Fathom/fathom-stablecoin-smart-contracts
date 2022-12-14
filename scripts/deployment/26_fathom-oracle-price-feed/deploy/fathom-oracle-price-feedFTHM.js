const fs = require('fs');

const FathomOraclePriceFeed = artifacts.require('./main/price-feeders/FathomOraclePriceFeed.sol');

const rawdata = fs.readFileSync('../../../../addresses.json');
let stablecoinAddress = JSON.parse(rawdata);
module.exports =  async function(deployer) {

  console.log(">> Deploying an upgradable FathomOraclePriceFeed contract")
  let promises = [
    deployer.deploy(FathomOraclePriceFeed, { gas: 4050000 }),
  ];

  await Promise.all(promises);

  const deployed = artifacts.require('./main/price-feeders/FathomOraclePriceFeed.sol');
  console.log(deployed.address);

  let addressesUpdate = { 
    fathomOraclePriceFeedFTHM:deployed.address,
  };
  console.log("fathomOraclePriceFeedFTHM is " + deployed.address);

  const newAddresses = {
    ...stablecoinAddress,  
    ...addressesUpdate
  };

  let data = JSON.stringify(newAddresses);
  fs.writeFileSync('./addresses.json', data);
};