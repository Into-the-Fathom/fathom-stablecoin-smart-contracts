const { getProxy } = require("../../../common/proxies");
const pools = require("../../../common/collateral");

const DeployerWallet = "0x4C5F0f90a2D4b518aFba11E22AC9b8F6B031d204";

module.exports =  async function(deployer) {
    const proxyFactory = await artifacts.initializeInterfaceAt("FathomProxyFactory", "FathomProxyFactory");

    const fathomStablecoin = await getProxy(proxyFactory, "FathomStablecoin");
    const accessControlConfig = await getProxy(proxyFactory, "AccessControlConfig");
    const collateralTokenAdapter = await getProxy(proxyFactory, "CollateralTokenAdapter");
    const fixedSpreadLiquidationStrategy = await getProxy(proxyFactory, "FixedSpreadLiquidationStrategy");
    // To be sunsetted on xdc mainnet, then to be deprecated
    // const stableSwap = await getProxy(proxyFactory, "StableSwapModule");
    // const stableSwapModuleWrapper = await getProxy(proxyFactory,"StableSwapModuleWrapper")

    await fathomStablecoin.grantRole(await fathomStablecoin.MINTER_ROLE(), DeployerWallet);

    await accessControlConfig.grantRole(await accessControlConfig.PRICE_ORACLE_ROLE(), DeployerWallet)
    await accessControlConfig.grantRole(await accessControlConfig.OWNER_ROLE(), DeployerWallet)

    await accessControlConfig.grantRole(await accessControlConfig.MINTABLE_ROLE(), DeployerWallet)
    
    // await stableSwap.addToWhitelist(DeployerWallet)
    // await stableSwapModuleWrapper.addToWhitelist(DeployerWallet)
    // await stableSwap.setStableSwapWrapper(
    //     stableSwapModuleWrapper.address,
    //     { gasLimit: 1000000 }
    // )
    
}