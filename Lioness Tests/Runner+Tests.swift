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
	
	enum RunnerTestError: Error {
		case sourceNotFound
		case executionFailed
		case resultNotFound
	}
	
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
		
		let sum = try? execute("InnerWhileLoops", get: "sum")
		
		XCTAssert(sum == 7_255_941_120, "Binary operation returned wrong result")
	
	}
	
	func testGCD() {
		
		let a = try? execute("GreatestCommonDivisor", get: "a")
		
		XCTAssert(a == 4, "Wrong result")
		
	}
	
	func testFibonacci() {
		
		let a = try? execute("Fibonacci", get: "a")
		
		XCTAssert(a == 55, "Wrong result")
		
	}
	
	func execute(_ file: String, get varName: String) throws -> Double {
	
		let runner = Runner(logDebug: false)
		
		let fileURL = getFilePath(for: file)
		
		guard let path = fileURL?.path else {
			throw RunnerTestError.sourceNotFound
		}
		
		do {
			
			let result = try runner.runSource(at: path, get: varName)
			
			return result
			
		} catch {
			throw RunnerTestError.executionFailed
		}
		
	}
	
}
