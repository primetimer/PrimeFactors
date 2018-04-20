//
//  RPNBig.swift
//  PFactors_Example
//
//  Created by Stephan Jancar on 19.10.17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import BigInt
import PrimeFactors

enum StackState : Int {
	case valid = 0, stored, cancelled, error, overflow, busy , prime, unimplemented, factorized, copied
}

enum CalcType : Int {
	case Undefined,Plus,Minus,Prod,Divide, LastX, Mersenne, Square, Cube, TenPow
	case PNext, PPrev, Sexy, Cousin, Twin, SoG, Rho, Squfof, Lehman, Factor, Factors
	case Swap, Pop, Pow, PowMod
	case Mod, gcd, sqrt, crt, Hash,Rnd
	case Sto1,Sto2,Sto3, Rcl1,Rcl2,Rcl3, CmdC, CmdV
}

class RPNCalc : CalcCancellable {
	
	override public init() {
		super.init()
		pcalc.canceldelegate = self
	}
	
	func Copy() -> RPNCalc {
		let copy = RPNCalc()
		copy.stackstate = self.stackstate
		for val in stack {
			copy.stack.append(val)
		}
		copy.sto = self.sto
		return copy
	}
	
	private let pcalc = ExtendedPrimeCalculator()
	private var bitMax = 1024
	var stackstate = StackState.valid
	var stack : [BigUInt] = []
	private var sto : [BigUInt] = [0,0,0]
	private var lastx : BigUInt = 0
	func push(x: BigUInt) {
		stack.insert(x, at: 0)
		if x.bitWidth > bitMax {
			self.stackstate = .overflow
		} else {
			self.stackstate = .valid
		}
	}
	func push() {
		let x = self.x
		stack.insert(x, at: 0)
	}
	
	private func popx() {
		lastx = x
		pop()
	}
	func pop() {
		if stack.count > 0 {
			stack.remove(at: 0)
		}
		stackstate = .valid
	}
	
	func Clear() {
		lastx = 0
		stack.removeAll()
		stackstate = .valid
	}
	
	public subscript(index: Int) -> BigUInt {
		if index >= stack.count {
			return BigUInt(0)
		}
		return stack[index]
	}

	var x : BigUInt {
		get {
			if stack.count > 0 { return stack[0] } else { return BigUInt(0)	}
		}
		set {
			if stack.count > 0 { stack[0] = newValue } else { push(x: newValue)	}
		}
	}
	
	var y : BigUInt {
		get {
			if stack.count > 1 { return stack[1] } else { return BigUInt(0) }
		}
		set {
			if stack.count > 1 { stack[1] = newValue } else { push(x: newValue)	}
		}
	}
	
	var z : BigUInt {
		get {
			if stack.count > 2 { return stack[2] } else { return BigUInt(0) }
		}
	}
	
	private func mod() {
		let ans = y % x
		popx()
		pop()
		push(x: ans)
		stackstate = .valid
	}
	
	private func powmod() {
		let ans = z.power(y, modulus: x)
		popx()
		pop()
		pop()
		push(x: ans)
		stackstate = .valid
	}
	
	private func PNext() {
		let ans = pcalc.NextPrime(n: x)
		popx()
		push(x: ans)
		stackstate = .prime
	}
	
	private func PPrev() {
		let ans = pcalc.PrevPrime(n: x)
		popx()
		push(x: ans)
		stackstate = .prime
	}

	private func pow() {
		if x > bitMax && (y>1) {
			stackstate = .overflow; return
		}
		if x == BigUInt(0) && y == BigUInt(0) {
			stackstate = .error
			return
		}
		if (x * BigUInt(y.bitWidth) > 2*bitMax) && (y>1)  {
			stackstate = .overflow
			return
		}
		
		let z = y.power(Int(x))
		popx()
		pop()
		push(x:z)
		stackstate = .valid
	}
	
	private func square() {
		let sq = x * x
		popx()
		push(x: sq)
		stackstate = .valid
	}
	private func cube() {
		let c = x * x * x
		popx()
		push(x: c)
		stackstate = .valid
	}
	private func tenpow() {
		if x > bitMax { stackstate = .overflow; return }
		let t = BigUInt(10).power(Int(x))
		popx()
		push(x: t)
		stackstate = .valid
	}
	
	
	private func mersenne() {
		if x < BigUInt(bitMax) {
			let m = BigUInt(2).power(Int(x)) - 1
			popx()
			push(x: m)
			stackstate = .valid
		} else {
			stackstate = .overflow
		}
	}
	
	private func plus() {
		let sum = x + y
		popx()
		pop()
		push(x: sum)
		stackstate = .valid
	}
	private func minus() {
		if y >= x {
			let dif = y-x
			popx()
			pop()
			push(x: dif)
			stackstate = .valid
		} else {
			self.stackstate = .error
		}
	}
	private func prod() {
		if x.bitWidth + y.bitWidth > bitMax {
			self.stackstate = .overflow
			return
		}
		let prod = x*y
		popx()
		pop()
		push(x: prod)
		stackstate = .valid
	}
	private func divide() {
		if x == 0 {
			stackstate = .error
			return
		}
		let div = y / x
		popx()
		pop()
		push(x: div)
		stackstate = .valid
	}
	
	private func Rho() {
		let rho = PrimeFaktorRho()
		
		if !x.isPrime() {
			let factor = rho.GetFactor(n: x, cancel: self)
			if factor < x && factor >= 2 {
				push(x: factor)
				stackstate = .valid
			}
			else {
				stackstate = .error
			}
		} else {
			stackstate = .prime
		}
		
	}
	
	private func Squfof() {
		let shanks = PrimeFactorShanks()

		if !x.isPrime() {
			let factor = shanks.GetFactor(n: x, cancel: self)
			if factor < x && factor >= 2 {
				push(x: factor)
				stackstate = .valid
			}
		} else {
			stackstate = .prime
		}
	}
	
	private func Lehman() {
		let lehman = PrimeFactorLehman()

		if !x.isPrime() {
			let factor = lehman.GetFactor(n: x, cancel: self)
			if factor < x && factor >= 2 {
				push(x: factor)
				stackstate = .valid
			}
		} else {
			stackstate = .prime
		}
	}
	
	private func twin(dif : Int = 2) {
		let twin = pcalc.NextTwin(n: x)
		popx()
		push(x: twin+2)
		push(x: twin)
		stackstate = .prime
	}
	
	private func sexy() {
		var p = pcalc.NextPrime(n: x)
		var p6 = p + 6
		while true {
			if pcalc.IsPrime(n: p6) { break }
			p = pcalc.NextPrime(n: p)
			p6 = p + 6
		}
		popx()
		push(x: p6)
		push(x: p)
		stackstate = .prime
	}
	private func cousin() {
		var p = pcalc.NextPrime(n: x)
		var p4 = p + 4
		while true {
			if pcalc.IsPrime(n: p4) { break }
			p = pcalc.NextPrime(n: p)
			p4 = p + 4
		}
		popx()
		push(x: p4)
		push(x: p)
		stackstate = .prime
	}
	
	private func sog() {
		let sog = pcalc.NextSoG(n: x)
		popx()
		push(x: 2*sog+1)
		push(x: sog)
		stackstate = .prime
	}
	
	private func factor() {
		stackstate = .unimplemented
	}
	private func factors() {
		let f = PrimeFactorStrategy()
		let ans = f.Factorize(ninput: x, cancel: self)
		popx()
		for p in ans {
			push(x: p)
		}
		stackstate = .factorized
	}
	
	private func swap() {
		let temp = y
		y = x
		x = temp
		stackstate = .valid
	}
	
	private func gcd() {
		let g = x.greatestCommonDivisor(with: y)
		popx()
		pop()
		push(x: g)
				stackstate = .valid
	}
	
	private func sqrt() {
		let ans = x.squareRoot()
		popx()
		push(x: ans)
				stackstate = .valid
	}
	private	func crt() {
		let ans = x.iroot3()
		popx()
		push(x: ans)
		stackstate = .valid
	}
	
	private func hash() {
		let hash = x.hashValue.toUint()
		popx()
		push(x: BigUInt(hash))
	}
	
	private func cmdc() {
		let pasteBoard = UIPasteboard.general
		pasteBoard.string = String(x)
		stackstate = .copied
	}
	private func cmdv() {
		let pasteBoard = UIPasteboard.general
		var numstr = ""
		var len = 0
		if  let str = pasteBoard.string {
			for c in Array(str) {
				switch c {
				case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9":
					numstr = numstr + String(c)
					len = len + 1
				default:
					break
				}
				if len > 100 { stackstate = .overflow; return }
			}
			
			
			if let nr = BigUInt(numstr) {
				push(x: nr)
			}
		}
	}
	
	private func rnd() {
		let limit = (x==0) ? 10000000000 : x
		let r = BigUInt.randomInteger(lessThan: limit)
		popx()
		push(x: r)
	}
	
	private func lastX() {
		push(x: lastx)
	}

	func Calculation(type : CalcType)
	{
		switch type {
		case .LastX:	lastX()
		case .CmdC: 	cmdc()
		case .CmdV:		cmdv()
		case .Plus:		self.plus()
		case .Minus:	self.minus()
		case .Prod:		self.prod()
		case .Divide:	self.divide()
		case .gcd:		self.gcd()
		case .sqrt:		self.sqrt()
		case .crt:		self.crt()
		case .Swap:		self.swap()
		case .Pop:		self.pop()
		case .PNext:	self.PNext()
		case .PPrev:	self.PPrev()
		case .Sexy:		self.sexy()
		case .Cousin: 	self.cousin()
		case .Pow:		self.pow()
		case .Mod:		self.mod()
		case .PowMod:	self.powmod()
		case .Twin:		self.twin()
		case .SoG:		self.sog()
		case .Rho:		self.Rho()
		case .Squfof:	self.Squfof()
		case .Lehman:	self.Lehman()
		case .Factor:	self.factor()
		case .Rnd:		self.rnd()
		case .Hash: 	self.hash()
		case .Square: 	self.square()
		case .Cube:		self.cube()
		case .TenPow:	self.tenpow()
		case .Mersenne: self.mersenne()
		case .Undefined:	break
		case .Factors:	self.factors()
		case .Sto1:		sto[0] = x; stackstate = .stored
		case .Sto2:		sto[1] = x; stackstate = .stored
		case .Sto3:		sto[2] = x;	stackstate = .stored
		case .Rcl1:		push(x: sto[0]); stackstate = .valid
		case .Rcl2:		push(x: sto[1]); stackstate = .valid
		case .Rcl3:		push(x: sto[2]); stackstate = .valid
		}
	}

}
