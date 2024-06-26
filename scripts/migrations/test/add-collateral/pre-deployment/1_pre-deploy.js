const fs = require('fs');
const { BigNumber } = require("ethers");

let addresses = JSON.parse(fs.readFileSync('../../../../../addresses.json'));
let addCollateral = JSON.parse(fs.readFileSync('../../../../../add-collateral.json'));

const ERC20 = artifacts.require('ERC20Mintable.sol');
const StableswapMultipleSwapsMock = artifacts.require("StableswapMultipleSwapsMock");
const TestOracleMock = artifacts.require("TestOracleMock");

const WeiPerRay = BigNumber.from(`1${"0".repeat(27)}`)

module.exports = async function (deployer) {
  const promises = [
    deployer.deploy(ERC20, "GLD", "GLD", { gas: 3050000 }),
    deployer.deploy(TestOracleMock, WeiPerRay, { gas: 7050000 }),
  ];

  await Promise.all(promises);

  const chainId = deployer.networkId(ERC20.address);
  addCollateral[chainId].fathomProxyFactory = addresses.proxyFactory;
  addCollateral[chainId].fathomProxyAdmin = addresses.proxyAdmin;
  addCollateral[chainId].testOracle = TestOracleMock.address;
  addCollateral[chainId].tokenAddress = ERC20.address;

  await deployer.deploy(StableswapMultipleSwapsMock, { gas: 3050000 })
  fs.writeFileSync('./add-collateral.json', JSON.stringify(addCollateral));
};