const fs = require('fs');

const CollateralTokenAdapter = artifacts.require('./main/stablecoin-core/adapters/FarmableTokenAdapter/CollateralTokenAdapter.sol');

const rawdata = fs.readFileSync('../../../../addresses.json');
let stablecoinAddress = JSON.parse(rawdata);

module.exports =  async function(deployer) {

  console.log(">> Deploying an upgradable CollateralTokenAdapterUSDT contract")
  let promises = [
      deployer.deploy(CollateralTokenAdapter, { gas: 5050000 }),
  ];

  await Promise.all(promises);

  const deployed = artifacts.require('./main/stablecoin-core/adapters/FarmableTokenAdapter/CollateralTokenAdapter.sol');

  let addressesUpdate = { 
    collateralTokenAdapterFTHM:deployed.address,
  };

  const newAddresses = {
    ...stablecoinAddress,  
    ...addressesUpdate
  };

  let data = JSON.stringify(newAddresses);
  fs.writeFileSync('./addresses.json', data);
};