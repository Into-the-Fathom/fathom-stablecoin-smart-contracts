const fs = require('fs');

const SimplePriceFeed = artifacts.require('./8.17/price-feeders/SimplePriceFeed.sol');

const rawdata = fs.readFileSync('../../../../addresses.json');
let stablecoinAddress = JSON.parse(rawdata);

module.exports =  async function(deployer) {

  console.log(">> Deploying an upgradable SimplePriceFeedFTHM contract")
  let promises = [
      deployer.deploy(SimplePriceFeed, { gas: 4050000 }),
  ];

  await Promise.all(promises);

  const deployed = artifacts.require('./8.17/price-feeders/SimplePriceFeed.sol');

  let addressesUpdate = { 
    simplePriceFeedFTHM:deployed.address,
  };

  const newAddresses = {
    ...stablecoinAddress,  
    ...addressesUpdate
  };
  console.log("SimplePriceFeedFTHM is " + deployed.address);
  let data = JSON.stringify(newAddresses);
  fs.writeFileSync('./addresses.json', data);
};