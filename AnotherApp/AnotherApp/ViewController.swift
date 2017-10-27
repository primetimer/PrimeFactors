//
//  ViewController.swift
//  AnotherApp
//
//  Created by Stephan Jancar on 26.10.17.
//  Copyright © 2017 Stephan Jancar. All rights reserved.
//

import UIKit
import BigInt
import PrimeFactors

class ViewController: UIViewController {

	override func viewDidLoad() {
		//Just some demo code to see whether it will compile
		let p = BigInt(2)
		let q = p.power(127)-1
		print(q)
		if q.isPrime() { print("IsPrime") }
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}

