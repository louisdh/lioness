//
//  Stdlib+Tests.swift
//  Lioness
//
//  Created by Louis D'hauwe on 06/01/2017.
//  Copyright © 2017 Silver Fox. All rights reserved.
//

import XCTest
@testable import Lioness

class Stdlib_Tests: BaseTestCase {
	
	enum StdlibTestError: Error {
		case sourceEmpty
		case sourceNotFound
	}
	
	override func setUp() {
		super.setUp()
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}
	
	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
		super.tearDown()
	}
	
	func getStdlibSource() throws -> String {
		
		let stdLib = StdLib()
		
		do {
			let source = try stdLib.stdLibCode()
			
			if source.isEmpty {
				throw StdlibTestError.sourceEmpty
			}
			
			return source
			
		} catch {
			throw StdlibTestError.sourceNotFound
		}
	
		
	}

	func testStdlibValidation() {
		
		do {
			
			_ = try getStdlibSource()
			
		} catch {
			XCTAssert(false, "Stdlib source error")
		}
		
	}
	
	func testStdlibCompilation() {

		guard let source = try? getStdlibSource() else {
			XCTAssert(false, "Stdlib source error")
			return
		}
		
		let runner = Runner()
		
		do {
			try runner.run(source)
		} catch {
			XCTAssert(false, "Stdlib run error")
		}
		
	}
	
}
