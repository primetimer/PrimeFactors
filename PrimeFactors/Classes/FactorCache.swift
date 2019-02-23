//
//  PrimeCache.swift
//  PFactors
//
//  Created by Stephan Jancar on 20.10.17.
//

import Foundation
import BigInt

public class FactorCache {
    
    //static let strat = PrimeFactorStrategyAsync() //Much too slow
    private var pcache = NSCache<NSString, PrimeFactors>()
    static public var shared = FactorCache()
    private let first : [UInt64] = [2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,71,73,79,83,89,97]
    
    private init() {}
    
    public func IsFactored(p: BigUInt) -> PrimeFactors? {
        if PrimeCache.shared.IsPrime(p: p) {
            return PrimeFactors(n: p)
        }
        
        //Already Factored in Cache?
        let nsstr = NSString(string: String(p.hashValue))
        if let cachep = pcache.object(forKey: nsstr) {
            return cachep
        }
        return nil
    }
    
    public func Factor(p: BigUInt, cancel : CalcCancelProt?) -> PrimeFactors {
        var ans = PrimeFactors(n: p)
        if ans.unfactored == 1 {
            return ans
        }
        let nsstr = NSString(string: String(p.hashValue))
        if let cachep = pcache.object(forKey: nsstr) {
            return cachep
        }
        //let factors = PrimeFactorStrategyAsync.shared.Factorize(n: p)
        let strat = PrimeFactorStrategy()
        ans = strat.Factorize(ninput: p, cancel: cancel)
        //        let nsarr = NSFactorArray(f: factors)
        pcache.setObject(ans, forKey: nsstr)
        return ans
    }
    
    public func Sigma(p: BigUInt, cancel: CalcCancelProt?) -> BigUInt? {
        if p == 0 { return 0 }
        if p == 1 { return 1 }
        var (ret,produkt) = (BigUInt(1),BigUInt(1))
        let factors = Factor(p: p, cancel: cancel)
        if factors.unfactored > 1 {
            return nil
        }
        let count = factors.factors.count
        if count == 0 { return ret }
        for i in 0..<count {
            produkt = produkt * factors.factors[i]
            if (i + 1 < count) && (factors.factors[i] == factors.factors [i+1]) {
                continue
            }
            ret = ret * ( produkt * (factors.factors[i]) - 1 ) / ((factors.factors[i]) - 1)
            produkt = BigUInt(1)
        }
        return ret
    }
    
    func Divisors(p: BigUInt,cancel: CalcCancelProt?) -> [BigUInt]
    {
        let factors = Factor(p: p,cancel: cancel)
        if cancel?.IsCancelled() ?? false { return [1,p] }
        let c = factors.factors.count
        if c == 0 { return [BigUInt(1)] }
        
        let d1 = factors.factors[0]
        var d1potenz : BigUInt = 1
        var multiplicity = 0
        while multiplicity < c {
            if factors.factors[multiplicity] != d1 {
                break
            }
            multiplicity = multiplicity + 1
            d1potenz = d1potenz * d1
        }
        
        //let ret : [UInt64] = []
        if c > multiplicity {
            
            let p2 = p/d1potenz
            var ret = Divisors(p: p2,cancel: cancel)
            if cancel?.IsCancelled() ?? false { return [1,p] }
            
            let n = ret.count
            d1potenz = d1
            for _ in 1...multiplicity {
                for i in 0..<n {
                    ret.append(d1potenz*ret[i])
                }
                d1potenz = d1potenz * d1
            }
            return ret
        }
        
        var ret : [BigUInt] = [BigUInt(1)]
        d1potenz = 1
        for _ in 1...multiplicity
        {
            d1potenz = d1 * d1potenz
            ret.append(d1potenz)
        }
        return ret
    }
}
