//
//  BytecodeVirtualHeader.swift
//  Lioness
//
//  Created by Louis D'hauwe on 12/01/2017.
//  Copyright © 2017 Silver Fox. All rights reserved.
//

import Foundation

public class BytecodeVirtualHeader: BytecodeLine {
	
	let id: Int
	
	private let name: String?
	private let arguments: [String]
	
	init(id: Int, name: String? = nil, arguments: [String] = []) {
		self.id = id
		self.name = name
		self.arguments = arguments
	}
	
	/// Debug description
	public var description: String {
		var descr = ""
		
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
