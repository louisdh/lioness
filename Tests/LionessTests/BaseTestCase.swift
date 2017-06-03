//
//  BaseTestCase.swift
//  Lioness
//
//  Created by Louis D'hauwe on 22/10/2016.
//  Copyright © 2016 - 2017 Silver Fox. All rights reserved.
//

import Foundation
import XCTest
@testable import Lioness

class BaseTestCase: XCTestCase {
	
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
	
	func getFilePath(for fileName: String) -> URL? {
		
		let bundle = Bundle(for: type(of: self))
		let fileURL = bundle.url(forResource: fileName, withExtension: "lion")
		
		return fileURL
		
	}
	
	func getSource(for fileName: String) -> String? {
		
		let fileURL = getFilePath(for: fileName)
		
		guard let path = fileURL?.path else {
			return nil
		}
		
		guard let source = try? String(contentsOfFile: path, encoding: .utf8) else {
			return nil
		}
		
		return source
		
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
