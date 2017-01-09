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
	
	// MARK: - Tests
	
	func testUnusedFunctionResult() {
		
		let interpreter = try? execute("UnusedFunctionResult")
		
		XCTAssert(interpreter?.stack.isEmpty == true, "Expected stack to be empty")
		
	}
	
	func testBinaryOp() {
		
		assert(in: "BinaryOp", that: "a", equals: 512.75)

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
	
	func testFunctionReturnGlobalVar() {
		
		assert(in: "FunctionReturnGlobalVar", that: "a", equals: 12)
		
	}
	
	func testFunctionInFunction() {
		
		assert(in: "FunctionInFunction", that: "a", equals: 100)
		
	}
	
	// MARK: - Boilerplate
	
	// TODO: Maybe set expectedValue in source file?
	func assert(in file: String, that `var`: String, equals expectedValue: Double) {
		
		let result = try? execute(file, get: `var`)
		
		let message = "[\(file).lion]: Expected \(expectedValue) as the value of \(`var`), but found: \(result)"
		XCTAssert(result == expectedValue, message)
		
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
	
	func execute(_ file: String) throws -> BytecodeInterpreter {
		
		let runner = Runner(logDebug: false)
		
		let fileURL = getFilePath(for: file)
		
		guard let path = fileURL?.path else {
			throw RunnerTestError.sourceNotFound
		}
		
		do {
			
			try runner.runSource(at: path)
			
			return runner.interpreter
			
		} catch {
			throw RunnerTestError.executionFailed
		}
		
	}
	
}
