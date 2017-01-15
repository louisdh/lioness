//
//  BytecodeStructHeader.swift
//  Lioness
//
//  Created by Louis D'hauwe on 12/01/2017.
//  Copyright © 2017 Silver Fox. All rights reserved.
//

import Foundation

// TODO: Merge with function header, rename to "virtual"
public class BytecodeStructHeader: BytecodeLine {
	
	let id: String
	let name: String?
	
	let members: [String]
	
	init(id: String, name: String? = nil, members: [String]) {
		self.id = id
		self.name = name
		self.members = members
	}
	
	/// Debug description
	public var description: String {
		var descr = ""
		
		if let name = name {
			descr += "\(name)("
			
			var isFirstMember = true
			
			for member in members {
				if !isFirstMember {
					descr += ","
				}
				descr += member
				
				isFirstMember = false
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
