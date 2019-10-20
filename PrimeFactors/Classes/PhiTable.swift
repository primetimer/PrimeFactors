//
//  PhiTable.swift
//  PrimeBase
//
//  Created by Stephan Jancar on 29.11.16.
//  Copyright © 2016 esjot. All rights reserved.
//

import Foundation

public class PhiTable {
	
	var usebackward = true //Use backward calculation via known pi
	var usecache = true
	
	var pcalc : PrimeCalculator!
	var pitable : PiTable!
	var maxpintable : UInt64 = 0
	var primorial : [UInt64] = []
	var primorial1 : [UInt64] = []
	
	var phi : [[UInt64]] = []
	var phitablesize = 7
	
	var phicache = NSCache<NSString, NSNumber>()
	
	func ReleaseCache() {
		phicache = NSCache<NSString, NSNumber>()
	}
    
    var first  : [UInt64] = [2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,71,73,79,83,89,97]

	
	private func CalcPrimorial(maxp: UInt64 = 23) { //23 because 2*3*...*23 < UInt32.max
		var prod : UInt64 = 1
		var prod1 : UInt64 = 1
		for p in self.first  {
			if p > maxp {
				break
			}
			prod = prod * p
			prod1 = prod1 * (p-1)
			primorial.append(prod)
			primorial1.append(prod1)
		}
	}
	
		
	init(pcalc : PrimeCalculator, pitable: PiTable, phitablesize : Int = 7) {
		//verbose = piverbose
		self.pcalc = pcalc
		self.pitable = pitable
		self.phitablesize = phitablesize
		self.maxpintable = pitable.Pin(m: pitable.ValidUpto())
		CalcPrimorial()
		Initphitable()
	}
	
	private func Initphitable()
	{
		phi = [[UInt64]] (repeating: [], count: phitablesize)
		for l in 0..<phitablesize
		{
			phi[l] = [UInt64] (repeating : 0, count : Int(primorial[l]))
			var count : UInt64 = 0
			for k in 0..<primorial[l]
			{
				var relativeprime = true
				for pindex in 0...l
				{
					let p = pitable.NthPrime(n: pindex+1)
					if k % p == 0 {
						relativeprime = false
						break
					}
				}
				if relativeprime {
					count = count + 1
				}
				phi[l][Int(k)] = count
			}
		}
	}
	
	
	
	//The Number of integers of the for form n = pi * pj
	//with pj >= pi > a-tth Prime
	func P2(x: UInt64, a: UInt64) -> UInt64 {
		
		#if true
			let starttime = CFAbsoluteTimeGetCurrent()
		#endif
		
        let r2 = x.squareRoot()
		let pib = pitable.Pin(m: r2)
		
		if a >= pib  { return 0 }
		var p2 : UInt64 = 0
		for i in a+1...pib {
			let p = pitable.NthPrime(n: Int(i))
			let xp = x / p
			let pi = pitable.Pin(m: xp)
			p2 = p2 + pi - (i - 1)
		}
		
		#if false
			phideltap2time = phideltap2time + CFAbsoluteTimeGetCurrent() - starttime
		#endif
		
		return p2
	}
	
	var rekurs = 0
	//The Number of integers of the for form n = pi * pj * pk
	//with k >= pj >= pi > a-tth Prime
	func P3(x: UInt64, a: UInt64) -> UInt64 {
		let r3 = x.iroot3()
		let pi3 = pitable.Pin(m: r3)
		if a >= pi3 { return 0 }
		
		var p3 : UInt64 = 0
		for i in a+1...pi3 {
			let p = pitable.NthPrime(n: Int(i))
			let xp = x / p
			let rxp = xp.squareRoot()
			let bi = pitable.Pin(m: rxp)
			
			for j in i...bi {
				let q = pitable.NthPrime(n: (Int(j)))
				let xpq = x / (p*q)
				let pixpq = pitable.Pin(m: xpq)
				
				p3 = p3 + pixpq - (j-1)
			}
		}
		return p3
	}
	//Calculates Phi aka Legendre sum
	func Phi(x: UInt64, nr: Int) -> UInt64 {
		
		if x == 0  { return 0  }
		assert (UInt64(nr) <= pitable.ValidUpto())
		
		// phi(x) = primorial1 * (x / primorial) + phitable
		
		if nr == 0 { return x }
		if nr == 1 { return x - x/2 }
		if nr == 2 { return x - x/2 - x/3 + x/6 }
		if nr == 3 { return x - x/2 - x/3 + x/6 - x/5 + x/10 + x/15 - x/30 }
		
		if x < pitable.NthPrime(n: nr+1) { return 1  }
		
		if nr < phitablesize {
			let t = x / primorial[nr-1]
			let r = x - primorial[nr-1] * t
			let q = primorial1[nr-1]
			let y = q * t + phi[nr-1][Int(r)]
			return y
		}
		
		
		
		//Look in Cache
		var nskey : NSString = ""
		if usecache && nr < 500 {
			let key = String(x) + ":" + String(nr)
			nskey = NSString(string: key)
			if let cachedVersion = phicache.object(forKey: nskey) {
				return cachedVersion.uint64Value
			}
		}
		
		
		
		rekurs = rekurs + 1
		let value = PhiCalc(x: x, nr: nr)
		if usecache && nr < 500 {
			let cachevalue = NSNumber(value: value)
			phicache.setObject(cachevalue, forKey: nskey)
		}
		
	
		//print("time: ",rekurs, x,nr,phideltafwdtime,phideltap2time)
		rekurs = rekurs - 1
		
		return value
		
		
	}
	
	var phideltafwdtime = 0.0
	var phideltap2time = 0.0
	
	private func IsPhiByPix(x: UInt64, a: Int) -> Bool
	{
		if x>maxpintable {
			return false
		}
		let pa = pitable.NthPrime(n: a)
		if x < pa*pa {
			return true
		}
		return false
	}
	
	private func PhiCalc(x: UInt64, nr : Int) -> UInt64
	{
		#if false
		if IsPhiByPix(x: x,a: nr) {
			let pix = pitable.Pin(m: x)
			let phi = pix - UInt64(nr) + 1
			return phi
		}
		#endif
		
		if usebackward && x < maxpintable {
			// Use backward Formula
			// phi = 1 + pi(x) - nr + P2(x,nr) + P3(x,nr)
			// for x in p(nr) ... p(nr+1)^4
			
			let pa = pitable.NthPrime(n: nr)
			//let pa1 = pitable.NthPrime(n: nr+1)
			
			if x <= pa {
				return 1
			}
			
			let papow2 = pa * pa
			let papow4 = papow2 * papow2
			#if false
				if pa1pow >= UInt64(UInt32.max / 2) { pa1pow = x+1 }  // to avoid overflow
				else {  pa1pow = pa1pow * pa1pow }
			#endif
			if x < papow4 {
				let pix = pitable.Pin(m: x)
				var p2 : UInt64 = 0
				if x >= papow2 {
					p2 = P2(x: x, a : UInt64(nr))
				}
				var p3 : UInt64 = 0
				if x >= pa * pa * pa {
					p3 = P3(x: x, a: UInt64(nr))
				}
				
				let phi = 1 + pix + p2 + p3 - UInt64(nr)
				return phi
			}
		}
		
		
		//Use forward Recursion
		#if true
			let starttime = CFAbsoluteTimeGetCurrent()
		#endif
		var result = Phi(x: x, nr: phitablesize - 1)
		
		#if false
			phideltafwdtime = phideltafwdtime + CFAbsoluteTimeGetCurrent() - starttime
		#endif
		
		var i = phitablesize
		while i <= nr {
			let p = self.pitable.NthPrime(n: i)
			let n2 = x / p
			if n2 < p { break }
			
			let dif = Phi(x: n2,nr: i-1)
			result = result - dif
			i = i + 1
			
		}
		var k = nr
        while x < self.pitable.NthPrime(n: k+1) {
			k = k - 1
		}
		let delta = (Int(i)-Int(k)-1)
		result = UInt64(Int(result) + delta)
		
		
		return result
	}
}






