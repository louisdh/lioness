//
//  StdLib.swift
//  Lioness
//
//  Created by Louis D'hauwe on 11/12/2016.
//  Copyright © 2016 Silver Fox. All rights reserved.
//

import Foundation

class StdLib {
	
	fileprivate let sources = ["Geometry"]
	
	func stdLibCode() throws -> String {
		
		var stdLib = ""
		
		let bundle = Bundle(for: type(of: self))
		
		for sourceName in sources {
			
			guard let path = bundle.path(forResource: sourceName, ofType: "lion", inDirectory: "Resources") else {
				throw StdLibError.resourceNotFound
			}
			
			let source = try String(contentsOfFile: path, encoding: .utf8)
			stdLib += source
			
		}
	
		return stdLib
	}

}

enum StdLibError: Error {
	case resourceNotFound
}
