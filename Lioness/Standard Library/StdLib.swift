//
//  StdLib.swift
//  Lioness
//
//  Created by Louis D'hauwe on 11/12/2016.
//  Copyright © 2016 - 2017 Silver Fox. All rights reserved.
//

import Foundation

class StdLib {
	
	fileprivate let sources = ["Arithmetic", "Geometry", "Graphics"]
	
	func stdLibCode() throws -> String {
		
		var stdLib = ""
		
		let bundle = Bundle(for: type(of: self))
		
		for sourceName in sources {
			
			guard let resourcesPath = bundle.resourcePath else {
				throw StdLibError.resourceNotFound
			}
			
			let resourcePath = "\(resourcesPath)/\(sourceName).lion"
			
			let source = try String(contentsOfFile: resourcePath, encoding: .utf8)
			stdLib += source
			
		}
				
		return stdLib
	}

}

enum StdLibError: Error {
	case resourceNotFound
}
