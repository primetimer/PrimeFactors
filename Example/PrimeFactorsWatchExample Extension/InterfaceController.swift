//
//  InterfaceController.swift
//  PrimeFactorsWatchExample Extension
//
//  Created by Stephan Jancar on 22.02.19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import WatchKit
import Foundation
import BigInt
import PrimeFactors

class InterfaceController: WKInterfaceController {

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        let x = 3*5*13*13
        let xu = BigUInt(x)
        
        let strat = PrimeFactorStrategy()
        let f = strat.Factorize(ninput: xu, cancel: nil)
        for fact in f.factors {
            print(fact)
        }
        
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
