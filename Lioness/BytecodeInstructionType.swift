//
//  BytecodeInstructionType.swift
//  Lioness
//
//  Created by Louis D'hauwe on 09/10/2016.
//  Copyright © 2016 Silver Fox. All rights reserved.
//

import Foundation

enum BytecodeInstructionType: String {
	
	case pushConst = "push_const"
	case add = "add"
	case sub = "sub"
	case mul = "mul"
	case div = "div"
	case pow = "pow"
	
	var command: String {
		
		return self.rawValue

	}
	
}
