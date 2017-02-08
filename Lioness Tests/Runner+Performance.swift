//
//  FullRun+Performance.swift
//  Lioness
//
//  Created by Louis D'hauwe on 20/10/2016.
//  Copyright © 2016 - 2017 Silver Fox. All rights reserved.
//

import XCTest
@testable import Lioness

/// Performance tests for full run (from lexer to interpreter)
class FullRun_Performance: BaseTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testLargeMathPerformance() {
		
		guard let source = getSource(for: "LargeMathOperation") else {
			XCTFail("Failed to get source")
			return
		}
				
        self.measure {

			let runner = Runner(logDebug: false)

			do {
				try runner.run(source)
			} catch {
				XCTFail(error.localizedDescription)
			}
			
		}
    }

	func testComplexPerformance() {

		guard let source = getSource(for: "Complex") else {
			XCTFail("Failed to get source")
			return
		}
		
		self.measure {
			
			let runner = Runner(logDebug: false)

			do {
				try runner.run(source)
			} catch {
				XCTFail(error.localizedDescription)
			}
			
		}
	}
	
}
