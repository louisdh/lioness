//
//  BaseTestCase.swift
//  Lioness
//
//  Created by Louis D'hauwe on 22/10/2016.
//  Copyright © 2016 Silver Fox. All rights reserved.
//

import Foundation
import XCTest
@testable import Lioness

class BaseTestCase: XCTestCase {
	
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

}
