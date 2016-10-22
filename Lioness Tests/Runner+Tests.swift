//
//  Runner+Tests.swift
//  Lioness
//
//  Created by Louis D'hauwe on 22/10/2016.
//  Copyright © 2016 Silver Fox. All rights reserved.
//

import XCTest
@testable import Lioness

class Runner_Tests: XCTestCase {
	
	override func setUp() {
		super.setUp()
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}
	
	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
		super.tearDown()
	}
	
	func testBinaryOp() {
		
		let runner = LionessRunner(logDebug: false)
		
		let source = "1 + 3 * (8^4 - 2) / 6 / 4"
		
		runner.runSource(source)

		guard let value = runner.interpreter?.stack.first else {
			XCTAssert(false, "Expected value at top of stack")
			return
		}
		
		XCTAssert(value == 512.75, "Binary operation returned wrong result")
		
	}
	
}
