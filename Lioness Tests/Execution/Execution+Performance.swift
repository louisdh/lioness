//
//  Execution+Performance.swift
//  Lioness
//
//  Created by Louis D'hauwe on 23/10/2016.
//  Copyright © 2016 Silver Fox. All rights reserved.
//

import XCTest
@testable import Lioness

/// Performance tests for execution.
/// (running of bytecode)
///
/// This will test the performance of compiled bytecode,
/// as well as the execution of it.
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
	
	func testLargeMathPerformance() {
		
		let fileURL = getFilePath(for: "LargeMathOperation")
		
		guard let path = fileURL?.path else {
			XCTFail("Invalid path for test")
			return
		}
		
		guard let source = try? String(contentsOfFile: path, encoding: .utf8) else {
			XCTFail("Failed to get source")
			return
		}
		
		let lexer = Lexer(input: source)
		let tokens = lexer.tokenize()
		
		let parser = Parser(tokens: tokens)
		let ast = try! parser.parse()
		
		self.measure {
			
			let compiler = BytecodeCompiler(ast: ast)
			let bytecode = try! compiler.compile()
			
			let interpreter = BytecodeInterpreter(bytecode: bytecode)
			try! interpreter.interpret()
			
		}
	}
	
}
