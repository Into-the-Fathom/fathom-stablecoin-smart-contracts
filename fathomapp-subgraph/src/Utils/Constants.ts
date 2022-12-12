import { BigDecimal, BigInt } from "@graphprotocol/graph-ts"

export class Constants{
    public static FATHOM_STATS_KEY:string = 'fathom_stats'
    public static DEFAULT_PRICE:BigDecimal = BigDecimal.fromString('0')

    public static ADDR_COLLATERAL_POOL_CONFIG:string = '0x0c17ba9B9cCF3aB166BDCffd1d6b3eA29bEf697d'
    public static ADDR_POSITION_MANAGER:string = '0x77CcfcDE7428Baa89bB634F112A8741C12B69F5e'

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