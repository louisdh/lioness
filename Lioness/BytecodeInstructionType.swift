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
public enum BytecodeInstructionType: String {
	
	case pushConst = "push_const"
	case add = "add"
	case sub = "sub"
	case mul = "mul"
	case div = "div"
	case pow = "pow"
	
	case and = "and"
	case or = "or"
	case not = "not"
	
	/// Equal
	case eq = "eq"
	/// Not equals
	case neq = "neq"
	
	case ifTrue = "if_true"
	case ifFalse = "if_false"

	/// Compare less than or equal
	case cmple = "cmple"
	/// Compare less than
	case cmplt = "cmplt"

	
	case goto = "goto"
	
	case registerStore = "reg_store"
	case registerClear = "reg_clear"
	case registerLoad = "reg_load"
	
	// TODO: To be implemented
//	case invokeFunc = "invoke_func"
	
	public var command: String {
		return self.rawValue
	}
	
}
