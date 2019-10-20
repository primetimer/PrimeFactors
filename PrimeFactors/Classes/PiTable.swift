//
//  PiTable.swift
//  PrimeBase
//
//  Created by Stephan Jancar on 30.11.16.
//  Copyright © 2016 esjot. All rights reserved.
//

import Foundation

//protocol PrimeCounter {
//
//    func ValidUpto() -> UInt64
//    func NthPrime(n: Int) -> UInt64
//    func Pin(m: UInt64) -> UInt64
//}

public class PinTable {
    
    static func PNT(n: UInt64) -> UInt64 {
        if n < 2 { return 0 }
        let x = Double(n)
        let d = x / log(x)
        return UInt64(d)
    }
    
    static func PNTLegendre(n: UInt64) -> UInt64 {
        if n < 2 { return 0 }
        let x = Double(n)
        let d = x / (log(x) - 1.083)
        return UInt64(d)
    }
    
    static func PNTUpperBound(n: UInt64) -> UInt64 {
        if n < 2 { return 0 }
        let d = ceil(1.25506 * Double(PNT(n: n)))+1
        return UInt64(d)
    }

    
    struct PiData
    {
        var pin : UInt64 = 0
        var bits : UInt64 = 0
    }
    
    private var it : PiTable!

    init(it : PiTable) {
        self.it = it
        
        let size = PinTable.PNTUpperBound(n: it.ValidUpto())
        self.pin = [PiData] (repeating: PiData() , count: Int(size))
        Fill()
    }
    
    private var pin : [PiData] = []
    
    func Pin(n: UInt64) -> UInt64 {
        
        let n64 = Int(n/64)
        let bitmask : UInt64 = UInt64.max >> (63 - n % 64)
        let pval = pin[n64]
        let ret = UInt64(pval.pin) + (UInt64(pval.bits) & bitmask).NumBits()
        return ret

    }
    
    private func Fill() {
        var p : UInt64 = 0
        var n : UInt64 = 1
        
        let valid = it.ValidUpto()
        while p < valid {
            p = it.NthPrime(n: Int(n))
            if p == 0 {
                break
            }
            let p64 = Int(p / 64)
            let mask = 1 << (p % 64)
            let bits = pin[p64].bits | mask
            pin[p64].bits = bits
            n = n + 1
        }
        
        var picount : UInt64 = 0
        for i in 0..<pin.count {
            pin[i].pin = picount
            picount = picount + pin[i].bits.NumBits()
        }
    }
}

public class PiTable {
    
    private var pcalc : PrimeCalculator!
    private var wheel : WheelSieve!
    
    private var maxturns  : UInt32 = 0
    private var circum : UInt32 = 0
    private let wheelspokes : Int = 2
    
    //The lastprime stored
    private var primeupto : UInt64 = 0
 
    
    //Stores the pi-count for every turn of the wheel
    var pintable : PinTable! = nil
    
    //The detected Primes
    var prime : [UInt32] = []
    
    func ValidUpto() -> UInt64 {
        return self.primeupto
    }
    
    public init(pcalc : PrimeCalculator, tableupto : UInt64) {
        
        self.pcalc = pcalc
        wheel = WheelSieve(limit: tableupto)
        
        let pnt : UInt64 = PinTable.PNTUpperBound(n: tableupto)
        //Allocate Space for primes
        prime = [UInt32] (repeating : 0, count : Int(pnt))
        
        self.primeupto = tableupto
        //Calculate Primes
        Fill()
        
        
        //Calculate PrimeCounting
        pintable = PinTable(it: self)
    }
    
    private func Fill() {
 
        var pin : UInt32 = 0
        
        for n in 2...wheel.limit {
            if wheel.IsPrime(n: n) {
                prime[Int(pin)] = UInt32(n)
                pin = pin + 1
            }
        }
    }
    
    //private var hint: Int = 0
    public func Pin(m: UInt64) -> UInt64 {
        
        if m < 2 { return 0 }
        if m < 3 { return 1 }
        if m < 5 { return 2 }
        if m < 7 { return 3 }
        if m < 11 { return 4 }
        if m < 13 { return 5 }
        if m < 17 { return 6 }
        
        if m > ValidUpto() {
            assert(false)
            return 0
        }
        
        return pintable.Pin(n: m)
     
        
    }
    
    public func NthPrime(n: Int) -> UInt64
    {
        assert(n>0)
        return UInt64(prime[n-1])
    }
}

