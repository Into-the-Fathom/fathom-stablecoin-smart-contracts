const { getProxy } = require("../../common/proxies");
const pools = require("../../common/collateral");

module.exports =  async function(deployer) {
    const proxyFactory = await artifacts.initializeInterfaceAt("FathomProxyFactory", "FathomProxyFactory");

    const fixedSpreadLiquidationStrategy = await getProxy(proxyFactory, "FixedSpreadLiquidationStrategy");
    const stabilityFeeCollector = await getProxy(proxyFactory, "StabilityFeeCollector");
    const stablecoinAdapter = await getProxy(proxyFactory, "StablecoinAdapter");
    const showStopper = await getProxy(proxyFactory, "ShowStopper");
    const priceOracle = await getProxy(proxyFactory, "PriceOracle");
    const fathomStablecoin = await getProxy(proxyFactory, "FathomStablecoin");
    const positionManager = await getProxy(proxyFactory, "PositionManager");
    const liquidationEngine = await getProxy(proxyFactory, "LiquidationEngine");
    const bookKeeper = await getProxy(proxyFactory, "BookKeeper");
    const accessControlConfig = await getProxy(proxyFactory, "AccessControlConfig");
    const flashMintModule = await getProxy(proxyFactory, "FlashMintModule");
    const stableSwapModule = await getProxy(proxyFactory, "StableSwapModule");
    const authTokenAdapter = await getProxy(proxyFactory, "AuthTokenAdapter");
    const collateralTokenAdapterFactory = await getProxy(proxyFactory, "CollateralTokenAdapterFactory");
    
    await accessControlConfig.grantRole(await accessControlConfig.BOOK_KEEPER_ROLE(), bookKeeper.address)
  
    await accessControlConfig.grantRole(await accessControlConfig.POSITION_MANAGER_ROLE(), positionManager.address)
    await accessControlConfig.grantRole(await accessControlConfig.COLLATERAL_MANAGER_ROLE(), positionManager.address)
  
    await accessControlConfig.grantRole(await accessControlConfig.STABILITY_FEE_COLLECTOR_ROLE(), stabilityFeeCollector.address)
  
    await accessControlConfig.grantRole(await accessControlConfig.LIQUIDATION_ENGINE_ROLE(), liquidationEngine.address)
  
    await accessControlConfig.grantRole(await accessControlConfig.LIQUIDATION_ENGINE_ROLE(), fixedSpreadLiquidationStrategy.address)
    await accessControlConfig.grantRole(await accessControlConfig.COLLATERAL_MANAGER_ROLE(), fixedSpreadLiquidationStrategy.address)
  
    await accessControlConfig.grantRole(await accessControlConfig.LIQUIDATION_ENGINE_ROLE(), showStopper.address)
    await accessControlConfig.grantRole(await accessControlConfig.COLLATERAL_MANAGER_ROLE(), showStopper.address)
  
    await accessControlConfig.grantRole(await accessControlConfig.PRICE_ORACLE_ROLE(), priceOracle.address)
  
    const collateralTokenAdapterWXDC = await collateralTokenAdapterFactory.adapters(pools.WXDC)
    const collateralTokenAdapterUSDT_stbl = await collateralTokenAdapterFactory.adapters(pools.USDT_STABLE)
    const collateralTokenAdapterUSDT_col = await collateralTokenAdapterFactory.adapters(pools.USDT_COL)
    const collateralTokenAdapterFTHM = await collateralTokenAdapterFactory.adapters(pools.FTHM)
  
    await accessControlConfig.grantRole(accessControlConfig.ADAPTER_ROLE(), collateralTokenAdapterWXDC)
    await accessControlConfig.grantRole(accessControlConfig.ADAPTER_ROLE(), collateralTokenAdapterUSDT_stbl)
    await accessControlConfig.grantRole(accessControlConfig.ADAPTER_ROLE(), collateralTokenAdapterUSDT_col)
    await accessControlConfig.grantRole(accessControlConfig.ADAPTER_ROLE(), collateralTokenAdapterFTHM)
  
    await accessControlConfig.grantRole(await accessControlConfig.MINTABLE_ROLE(), flashMintModule.address)
  
    await accessControlConfig.grantRole(accessControlConfig.ADAPTER_ROLE(), authTokenAdapter.address)
  
    await authTokenAdapter.grantRole(await authTokenAdapter.WHITELISTED(), stableSwapModule.address)
  
    await accessControlConfig.grantRole(await accessControlConfig.POSITION_MANAGER_ROLE(), stableSwapModule.address)
    await accessControlConfig.grantRole(await accessControlConfig.COLLATERAL_MANAGER_ROLE(), stableSwapModule.address)

    await fathomStablecoin.grantRole(await fathomStablecoin.MINTER_ROLE(), stablecoinAdapter.address);
}