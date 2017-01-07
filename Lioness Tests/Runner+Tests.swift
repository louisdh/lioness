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
		
		assert(in: "InnerWhileLoops", that: "sum", equals: 7_255_941_120)

	}
	
	func testGCD() {
		
		assert(in: "GreatestCommonDivisor", that: "a", equals: 4)

	}
	
	func testFibonacci() {
		
		assert(in: "Fibonacci", that: "a", equals: 55)

	}
	
	func testFunctionGlobalVar() {
		
		assert(in: "FunctionGlobalVar", that: "a", equals: 12)
		
	}
	
	func testDoTimesLoops() {
		
		assert(in: "DoTimesLoops", that: "a", equals: 10000)
		
	}
	
	func assert(in file: String, that varName: String, equals expectedValue: Double) {
		
		let result = try? execute(file, get: varName)
		
		XCTAssert(result == expectedValue, "Wrong result")
		
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
