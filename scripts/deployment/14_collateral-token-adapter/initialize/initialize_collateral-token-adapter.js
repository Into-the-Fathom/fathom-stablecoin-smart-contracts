const fs = require('fs');
const rawdata = fs.readFileSync('../../../../addresses.json');
let stablecoinAddress = JSON.parse(rawdata);
const { formatBytes32String } = require("ethers/lib/utils");
const { BigNumber } = require("ethers");

const COLLATERAL_POOL_ID = formatBytes32String("WXDC")

const CollateralTokenAdapter = artifacts.require('./main/stablecoin-core/adapters/FarmableTokenAdapter/CollateralTokenAdapter.sol');

//for testnet
// const deployerAddress = "0x46b5Da5314658b2ebEe832bB63a92Ac6BaedE2C0";
// const devAddress = "0x46b5Da5314658b2ebEe832bB63a92Ac6BaedE2C0";

//for ganache
const deployerAddress = accounts[0];
const devAddress = accounts[0];

// require("dotenv").config();
// const WXDCAdd = process.env.WXDC_ADDRESS;

module.exports =  async function(deployer) {
  console.log(">> Initializing collateralTokenAdapter")
  // const collateralTokenAdapter = await artifacts.initializeInterfaceAt("ICollateralTokenAdapter", stablecoinAddress.collateralTokenAdapter);

  const collateralTokenAdapter = await CollateralTokenAdapter.at(stablecoinAddress.collateralTokenAdapter);
  
  await collateralTokenAdapter.initialize(
    stablecoinAddress.bookKeeper,
    COLLATERAL_POOL_ID,
    // WXDCAdd,             //COLLATERAL_TOKEN_ADDR
    stablecoinAddress.WXDC,
    stablecoinAddress.fathomToken,  //Reward token addr
    stablecoinAddress.fairLaunch,
    0,  // Pool ID
    stablecoinAddress.shield,   //  deployerAddress as sheild
    deployerAddress,                 // deployer as TIME_LOCK
    BigNumber.from(1000),                   //TREASURY_FEE_BPS 1000
    devAddress,                 // deployer asTREASURY_ACCOUNT
    stablecoinAddress.positionManager
    , { gasLimit: 5000000 }
    )
};