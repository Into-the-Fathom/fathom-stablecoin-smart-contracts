const fs = require('fs');

const { ethers, upgrades } = require("hardhat");

const rawdata = fs.readFileSync('./addresses.json');
let stablecoinAddress = JSON.parse(rawdata);
async function main() {

  console.log(">> Deploying an upgradable FixedSpreadLiquidationStrategy contract")
  const FixedSpreadLiquidationStrategy = (await ethers.getContractFactory(
    "FixedSpreadLiquidationStrategy",
    (
      await ethers.getSigners()
    )[0]
  ))
  const fixedSpreadLiquidationStrategy = await upgrades.deployProxy(FixedSpreadLiquidationStrategy, [
    stablecoinAddress.bookKeeper,
    stablecoinAddress.priceOracle,
    stablecoinAddress.liquidationEngine,
    stablecoinAddress.systemDebtEngine,
  ])
  await fixedSpreadLiquidationStrategy.deployed()
  console.log(`>> Deployed at ${fixedSpreadLiquidationStrategy.address}`)
  const tx = await fixedSpreadLiquidationStrategy.deployTransaction.wait()
  console.log(`>> Deploy block ${tx.blockNumber}`)

  let addressesUpdate = { 
    fixedSpreadLiquidationStrategy: fixedSpreadLiquidationStrategy.address,
  };

  const newAddresses = {
    ...stablecoinAddress,  
    ...addressesUpdate
  };

  const newData = JSON.stringify(newAddresses);
  fs.writeFile("./addresses.json", newData, err => {
    if(err) throw err;
    console.log("New address added");
  })
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
