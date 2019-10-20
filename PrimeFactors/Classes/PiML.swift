//
//  PiMeisselLehmer.swift
//  PrimeBase
//
//  Created by Stephan Jancar on 04.12.16.
//  Copyright © 2016 esjot. All rights reserved.
//

import Foundation

public class PiMeisselLehmer {
    
    var pcalc : PrimeCalculator!
    var phicalc : PhiTable!
    var pitable : PiTable!
    
    public init(pcalc : PrimeCalculator, pitable : PiTable)
    {
        /*
        let nrmax : UInt64 = 1000000000 * 1000000000
        let tmax = PrimeHelper.iroot3(n: nrmax)
        let pmax = tmax * 5
        */
        
        self.pcalc = pcalc
        self.pitable = pitable
        self.phicalc = PhiTable(pcalc: pcalc, pitable: pitable)
        
    }
    
    public func Pin(n : UInt64) -> UInt64 {
        if n < pitable.ValidUpto() {
            return pitable.Pin(m: n)
        }
        return PinML(n: n)
    }
    
    func PinTable(n : UInt64) -> UInt64 {
        let count = pitable.Pin(m: n)
        return count
    }
    
    private func CalcMArbitrary(r2: UInt64, r3: UInt64) -> UInt64
    {
        let M = (r2 + r3) / 2 + 1
        return M
    }
    
    func PinML(n: UInt64) -> UInt64 {
        
        if n < pitable.ValidUpto() {
            return pitable.Pin(m: n)
        }
        
        let r2 = n.squareRoot()
        let r3 = n.iroot3()
        //_ = Pin(n: r2)
        //let pi3 = Pin(n: r3)
       
        let m = CalcMArbitrary(r2: r2,r3: r3)
        let pinm = Pin(n: m)
        let phi = phicalc.Phi(x: n, nr: Int(pinm))
        
        var pindex = pitable.Pin(m: m)
        var p2 : UInt64 = 0

        while true {
            let p = pitable.NthPrime(n: Int(pindex+1))
            if p <= m {
                pindex = pindex + 1
                continue
            }
            if p > r2 {
                break
            }
            let y = n / p
            let piny = Pin(n: y)
            p2 = p2 + piny - UInt64(pindex) 
            pindex = pindex + 1
        }
        
        let pi = phi + pinm - p2 - 1
        return pi
    }
}
