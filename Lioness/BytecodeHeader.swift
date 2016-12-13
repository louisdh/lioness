//
//  BytecodeHeader.swift
//  Lioness
//
//  Created by Louis D'hauwe on 11/12/2016.
//  Copyright © 2016 Silver Fox. All rights reserved.
//

import Foundation

public class BytecodeEnd: BytecodeLine {

	/// Debug description
	public var description: String {
		return "end\n"
	}
	
	public var encoded: String {
		// TODO: encode properly

		return ""
	}
	
}

public class BytecodeFunctionHeader: BytecodeLine {

	let id: String
	let name: String?
	
	let arguments: [String]

	init(id: String, name: String? = nil, arguments: [String] = []) {
		self.id = id
		self.name = name
		self.arguments = arguments
	}
	
	/// Debug description
	public var description: String {
		var descr = "\n"
		
		if let name = name {
			descr += "\(name)("
			
			var isFirstArg = true
			
			for arg in arguments {
				if !isFirstArg {
					descr += ","
				}
				descr += arg
				
				isFirstArg = false
			}
			
			descr += ")"
		}
		
		descr += ":"
		
		descr += "; virtual #\(id)".byAppendingLeading(" ", max(1, 30 - descr.characters.count))

		return descr
	}
	
	public var encoded: String {
		
		// TODO: encode properly
		
		var descr = "\(id)"
		
		descr += "()"
		
		descr += ":"
		
		return descr
	}
	
}

public class BytecodeMainHeader: BytecodeLine {

	init() {
		
	}
	
	/// Debug description
	public var description: String {
		return "main:"
	}
	
	public var encoded: String {
		
		// TODO: encode properly

		return ""
	}
	
}
