//
//  Runner+Tests.swift
//  Lioness
//
//  Created by Louis D'hauwe on 22/10/2016.
//  Copyright © 2016 - 2017 Silver Fox. All rights reserved.
//

import XCTest
@testable import Lioness

class Runner_Tests: BaseTestCase {
	
	override func setUp() {
		super.setUp()
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}
	
	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
		super.tearDown()
	}
	
	func testBinaryOp() {
		
		let runner = Runner(logDebug: false)
		
		let source = "1 + 3 * (8^4 - 2) / 6 / 4"
		
		do {
			try runner.run(source)
		} catch {
			XCTFail("Expected value at top of stack")
			return
		}

		guard let value = runner.interpreter?.stack.first else {
			XCTFail("Expected value at top of stack")
			return
		}
		
		XCTAssert(value == 512.75, "Binary operation returned wrong result")
		
	}
	
	func testInnerWhileLoops() {
		
		let runner = Runner(logDebug: false)

		let fileURL = getFilePath(for: "InnerWhileLoops")

		guard let path = fileURL?.path else {
			XCTFail("Invalid path for test")
			return
		}
		
		do {
			
			let sum = try runner.runSource(at: path, get: "sum")
			
			XCTAssert(sum == 7_255_941_120, "Binary operation returned wrong result")
		
		} catch {
			XCTFail("Failed to run")
			return
		}
	
	}
	
}
