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
		return "end"
	}
	
	public var encoded: String {
		// TODO: encode properly

		return ""
	}
	
}

public class BytecodeFunctionHeader: BytecodeLine {

	let name: String?
	let id: String
	
	init(name: String? = nil, id: String) {
		self.name = name
		self.id = id
	}
	
	/// Debug description
	public var description: String {
		var descr = ""
		
		if let name = name {
			descr += "\(name)()"
		}
		
		descr += ":"
		
		descr += "\t\t; virtual #\(id)"

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
