import { BigDecimal, BigInt } from "@graphprotocol/graph-ts"

export class Constants{
    public static FATHOM_STATS_KEY:string = 'fathom_stats'
    public static DEFAULT_PRICE:BigDecimal = BigDecimal.fromString('0')

    public static ADDR_COLLATERAL_POOL_CONFIG:string = '0xCa77B1822213C46EeD8c266680789b9Ad9c60Aa6'
    public static ADDR_POSITION_MANAGER:string = '0x2Ba9a69CFcA59A943BC427c7156875364D592a51'

    public static WAD:BigInt = BigInt.fromI64(10**18)
    public static RAY:BigInt = BigInt.fromI64( 10**27)
    public static RAD:BigInt = BigInt.fromI64( 10**45)

    public  static divByRAY(number: BigInt): BigInt {
        return number.div(Constants.WAD).div(BigInt.fromI64(10**9))
    }

    public  static divByRAYToDecimal(number: BigInt): BigDecimal {
        return number.toBigDecimal().div(Constants.WAD.toBigDecimal()).div(BigInt.fromI64(10**9).toBigDecimal())
    }

    public  static divByRAD(number: BigInt): BigInt {
        return number.div(Constants.WAD).div(Constants.WAD).div(BigInt.fromI64(10**9))
    }
}