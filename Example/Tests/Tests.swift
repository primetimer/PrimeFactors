import UIKit
import XCTest
import BigInt
import PrimeFactors


class Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        let n = BigUInt(1344)
        let d = FactorCache.shared.Divisors(p: n, cancel: nil)
       // XCTAssert(true, "Pass")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure() {
            // Put the code you want to measure the time of here.
        }
    }
    
}


/*
class MLTests: XCTestCase {
    
    var pcalc : PrimeCalculator!
    var pitable : PiTable!
    var ml : PiMeisselLehmer!
    override func setUp() {
        super.setUp()
        self.pcalc = PrimeCalculator()
        self.pitable = PiTable(pcalc: pcalc, tableupto: 1000000)
        self.ml = PiMeisselLehmer(pcalc: pcalc, pitable: pitable)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        let n = BigUInt(19)
        let pin = ml.Pin(n: UInt64(n))
        print("Pin:",pin)
        XCTAssert(true, "Pass")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
*/
