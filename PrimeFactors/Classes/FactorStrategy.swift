//
//  FactorStrategy.swift
//  PFactors
//
//  Created by Stephan Jancar on 18.10.17.
//


import Foundation
import BigInt

public class PrimeFactors : NSObject {
	public var n : BigUInt
	public var factors : [BigUInt]
	public var unfactored : BigUInt

	func completed() -> Bool {
		if unfactored == 1 {
			return true
		}
		return false
	}
	
	public init(n: BigUInt) {
		self.n = n
		self.unfactored = n
		self.factors = []
		
		if n < 2 {
			unfactored = 1
		}
		if PrimeCache.shared.IsPrime(p: n) {
			factors.append(n)
			unfactored = 1
		}
	}
	func Append(f: BigUInt) {
		factors.append(f)
		self.unfactored = self.unfactored / f
	}
}


public class PrimeFactorStrategy {
	
	var verbose = false
	private let first : [UInt64] = [2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,71,73,79,83,89,97]
	private var rho : PrimeFaktorRho!
	private var shanks : PrimeFactorShanks!
	private var lehman : PrimeFactorLehman!
	
	public init() {
		self.rho = PrimeFaktorRho()
		self.shanks = PrimeFactorShanks()
		self.lehman = PrimeFactorLehman()
//		self.canceldelegate = cancel
//		self.rho.canceldelegate = cancel
//		self.shanks.canceldelegate = cancel
//		self.lehman.canceldelegate = cancel
	}
	
	private func IsCancelled(cancel: CalcCancelProt?) -> Bool {
		return cancel?.IsCancelled() ?? false
	}
	
    private func QuickTrial(ninput: BigUInt) -> PrimeFactors {
        if verbose { print ("QuickTrial") }
        let factors = PrimeFactors(n: ninput)
        for p in first {
            let bigp = BigUInt(p)
            if bigp * bigp > factors.unfactored { break }
            while factors.unfactored % bigp == 0 {
                //                nn = nn / bigp
                factors.Append(f: bigp)
                factors.unfactored = factors.unfactored / bigp
                if verbose { print("Factor:",bigp) }
            }
        }
        return factors
    }
//    private func QuickTrial(ninput: BigUInt) -> PrimeFactors {
//        if verbose { print ("QuickTrial") }
//        var factors = PrimeFactors(n: ninput)
//        for p in first {
//            let bigp = BigUInt(p)
//            if bigp * bigp > factors.unfactored { break }
//            while factors.unfactored % bigp == 0 {
////                nn = nn / bigp
//                factors.Append(f: bigp)
//                if verbose { print("Factor:",bigp) }
//            }
//        }
//        return factors
//    }
	
	public func Factorize(ninput: BigUInt, cancel: CalcCancelProt?) -> PrimeFactors {
		
		//1. Probedivision fuer sehr kleine Faktoren
        let factors = QuickTrial(ninput: ninput)
		if factors.unfactored == 1 { return factors }
		if IsCancelled(cancel: cancel) { return factors }
		
		//2. Pollards-Rho Methode fuer kleine Zahlen zur Abspaltung von Faktoren bis zur vierten Wurzel
		let rhoupto = ninput.squareRoot().squareRoot()
		while factors.unfactored > rhoupto { //Heuristik
			if IsCancelled(cancel: cancel) { return factors }
			if verbose { print ("Rho") }
			//Rest schon prim, dann fertig
			if factors.unfactored.isPrime() {
				factors.Append(f: factors.unfactored)
//				if verbose { print("Factor:",factors.unfactored) }
				return factors
			}
			
			//Suche mit Pollards-Methode
			let factor = rho.GetFactor(n: factors.unfactored, cancel: cancel)
			
			//Nichts gefunden, dann weiter mit der nächsten Methode
			if factor == 0 { break }
			
			//Ist der gefunden Faktor prim
			if !factor.isPrime() {
				//Der gefundene Faktor war nicht prim, dann zerlegen
				let subfactors = self.Factorize(ninput: factor, cancel: cancel)
				for s in subfactors.factors {
					factors.Append(f: s);
					if verbose { print("Factor:",s) }
//					nn = nn / s
					
				}
			} else {
				//Primfaktor abspalten
				factors.Append(f: factor)
				if verbose { print("Factor:",factor) }
				//nn = nn / factor
			}
		}
		
		//Wechsle zu Shanks
		while factors.unfactored > 1 {
			if IsCancelled(cancel: cancel) { return factors }
			if verbose { print("Shanks") }
			//Rest schon prim, dann fertig
			if factors.unfactored.isPrime() {
				factors.Append(f: factors.unfactored)
//				if verbose { print("Factor:",nn) }
				return factors
			}
			
			//Shanks anwenden
			let factor = shanks.GetFactor(n: factors.unfactored, cancel: cancel)
			if factor == 0 { break }
			
			//Ist der gefunden Faktor prim
			if !factor.isPrime() {
				//Der gefundene Faktor war nicht prim, dann zerlegen (unwahrscheinlich)
				let subfactors = self.Factorize(ninput: factor, cancel: cancel)
				for s in subfactors.factors {
					factors.Append(f:s)
					if verbose { print("Factor:",s) }
//					nn = nn / s
					
				}
			} else {
				//Primfaktor abspalten
				factors.Append(f: factor)
				if verbose { print("Factor:",factor) }
//				nn = nn / factor
			}
		}
		
		//3. Letzte Retturn Fermattest
		while factors.unfactored > 1 {
			if IsCancelled(cancel: cancel) { return factors }
			if verbose { print("Fermat") }
			if factors.unfactored.isPrime() {
				factors.Append(f: factors.unfactored)
//				if verbose { print("Factor:",nn) }
				return factors
			}
			
			let factor = lehman.GetFactor(n: factors.unfactored, cancel: cancel)
			if factor.isPrime() {
				factors.Append(f: factor)
			}
			else {
				let subfactors = Factorize(ninput: factor, cancel: cancel)
				for s in subfactors.factors {
					factors.Append(f: s)
					if verbose { print("Factor:",s) }
				}
			}
//			nn = nn / factor
		}
		return factors
	}
	
	public func Factorize(s: String) -> String {
		var ans = ""
		guard let n = BigUInt(s) else { return "" }
		let factors = Factorize(ninput: n, cancel: nil)
		var start = true
		for f in factors.factors {
			if !start { ans = ans + "*" }
			ans.append(String(f))
			start = false
		}
		if factors.unfactored > 1 {
			ans.append("*?")
		}
		return ans
	}
}

