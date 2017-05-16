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
	
	// MARK: - Tests
	
	func testUnusedFunctionResult() {
		
		let interpreter = try? execute("UnusedFunctionResult")
		
		XCTAssert(interpreter?.stack.isEmpty == true, "Expected stack to be empty")
	}
	
	func testUnicodeSumFunction() {
		assert(in: "UnicodeSumFunction", that: "😀", equals: .number(5))
	}
	
	func testBinaryOp() {
		assert(in: "BinaryOp", that: "a", equals: .number(512.75))
	}
	
	func testInnerWhileLoops() {
		assert(in: "InnerWhileLoops", that: "sum", equals: .number(7_255_941_120))
	}
	
	func testGCD() {
		assert(in: "GreatestCommonDivisor", that: "a", equals: .number(4))
	}
	
	func testFibonacci() {
		assert(in: "Fibonacci", that: "a", equals: .number(55))
	}
	
	func testFunctionGlobalVar() {
		assert(in: "FunctionGlobalVar", that: "a", equals: .number(12))
	}
	
	func testDoTimesLoops() {
		assert(in: "DoTimesLoops", that: "a", equals: .number(10000))
	}
	
	func testFunctionReturnGlobalVar() {
		assert(in: "FunctionReturnGlobalVar", that: "a", equals: .number(12))
	}
	
	func testFunctionInFunction() {
		assert(in: "FunctionInFunction", that: "a", equals: .number(100))
	}
	
	func testVarAssignAfterScopeLeave() {
		assert(in: "VarAssignAfterScopeLeave", that: "a", equals: .number(1))
	}
	
	// MARK: - Boilerplate
	
	// TODO: Maybe set expectedValue in source file?
	func assert(in file: String, that `var`: String, equals expectedValue: ValueType, useStdLib: Bool = true) {
		
		guard let result = try? execute(file, get: `var`, useStdLib: useStdLib) else {
			
			let message = "[\(file).lion]: Expected \(expectedValue) as the value of \(`var`), but found: nil"

			XCTAssert(false, message)
			
			return
		}
		
		let message = "[\(file).lion]: Expected \(expectedValue) as the value of \(`var`), but found: \(result)"
		XCTAssert(result == expectedValue, message)
		
	}
	
	func execute(_ file: String, get varName: String, useStdLib: Bool = true) throws -> ValueType {
	
		let runner = Runner(logDebug: false)
		
		let fileURL = getFilePath(for: file)
		
		guard let path = fileURL?.path else {
			throw RunnerTestError.sourceNotFound
		}
		
		do {
			
			let result = try runner.runSource(at: path, get: varName, useStdLib: useStdLib)
			
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
			
			guard let interpreter = runner.interpreter else {
				throw RunnerTestError.executionFailed
			}
			
			return interpreter
			
		} catch {
			throw RunnerTestError.executionFailed
		}
		
	}
	
}
