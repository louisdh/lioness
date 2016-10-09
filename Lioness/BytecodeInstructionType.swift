//
//  BytecodeInstructionType.swift
//  Lioness
//
//  Created by Louis D'hauwe on 09/10/2016.
//  Copyright © 2016 Silver Fox. All rights reserved.
//

import Foundation

/// Bytecode Instruction Type
///
/// Enum cases are lower camel case (per Swift guideline)
///
/// Instruction commands are lower snake case
enum BytecodeInstructionType: String {
	
	case pushConst = "push_const"
	case add = "add"
	case sub = "sub"
	case mul = "mul"
	case div = "div"
	case pow = "pow"
	case goto = "goto"
	
	// TODO: To be implemented
//	case invokeFunc = "invoke_func"
	
	var command: String {
		return self.rawValue
	}
	
}
