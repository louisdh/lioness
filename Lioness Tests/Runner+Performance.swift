//
//  FullRun+Performance.swift
//  Lioness
//
//  Created by Louis D'hauwe on 20/10/2016.
//  Copyright © 2016 Silver Fox. All rights reserved.
//

import XCTest
import Lioness

class FullRun_Performance: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testLargeMathPerformance() {
		
		let runner = LionessRunner(logDebug: false)

		let path = "/Users/louisdhauwe/Desktop/Swift/Lioness/Lioness Tests/LargeMathOperation.lion"
		let source = try! String(contentsOfFile: path, encoding: .utf8)
		
        self.measure {

			runner.runSource(source)

		}
    }

}
