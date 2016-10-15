//
//  Lioness_Tests.swift
//  Lioness Tests
//
//  Created by Louis D'hauwe on 14/10/2016.
//  Copyright © 2016 Silver Fox. All rights reserved.
//

import XCTest
import Foundation
import Lioness

class Lioness_Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        let source = "a = 0.3"
		
		let lexer = Lexer(input: source)
		let tokens = lexer.tokenize()
		
		assert(tokens.count == 3)
		
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
