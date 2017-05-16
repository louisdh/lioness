//
//  Execution+Performance.swift
//  Lioness
//
//  Created by Louis D'hauwe on 23/10/2016.
//  Copyright © 2016 - 2017 Silver Fox. All rights reserved.
//

import XCTest
@testable import Lioness

/// Performance tests for execution.
/// (running of bytecode)
///
/// This will test the execution performance of compiled bytecode.
///
/// Compiler optimizations should be tested here.
class Execution_Performance: BaseTestCase {
	
	override func setUp() {
		super.setUp()
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}
	
	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
		super.tearDown()
	}
	
	func testTrigonometryPerformance() {
		doExecutionTest(for: "Trigonometry")
	}
	
	func testModulusPerformance() {
		doExecutionTest(for: "Modulus")
	}
	
	func testLargeMathPerformance() {
		doExecutionTest(for: "LargeMathOperation", repeatSource: 100)
	}
	
	func testComplexPerformance() {
		doExecutionTest(for: "Complex", repeatSource: 100)
	}
	
	func doExecutionTest(for fileName: String, repeatSource: Int = 1) {
		
		guard let bytecode = preparePerformanceTest(for: fileName) else {
			XCTFail("Failed to get source for \(fileName)")
			return
		}
		
		self.measure {
			for _ in 1...repeatSource {
				self.execute(bytecode)
			}
		}
		
	}
	
	func preparePerformanceTest(for file: String) -> [BytecodeExecutionInstruction]? {
		
		let runner = Runner()
		
		guard let stdLib = try? StdLib().stdLibCode() else {
			XCTFail("Failed to get stdlib")
			return nil
		}
		
		guard let compiledStdLib = runner.compileLionessSourceCode(stdLib) else {
			XCTFail("Failed to compile stdlib")
			return nil
		}
		
		guard let source = getSource(for: file) else {
			XCTFail("Failed to get source")
			return nil
		}
		
		guard let compiledSource = runner.compileLionessSourceCode(source) else {
			XCTFail("Failed to compile stdlib")
			return nil
		}
		
		let bytecode = compiledStdLib + compiledSource
		
		let executionBytecode = bytecode.map { $0.executionInstruction }

		return executionBytecode

	}
	
	func execute(_ bytecode: [BytecodeExecutionInstruction]) {
		
		let interpreter = try! BytecodeInterpreter(bytecode: bytecode)
		try! interpreter.interpret()
		
	}
	
}
