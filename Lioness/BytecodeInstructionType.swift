//
//  BytecodeInstructionType.swift
//  Lioness
//
//  Created by Louis D'hauwe on 09/10/2016.
//  Copyright © 2016 Silver Fox. All rights reserved.
//

import Foundation

/// Scorpion Bytecode Instruction Type
///
/// Enum cases are lower camel case (per Swift guideline)
///
/// Instruction command descriptions are lower snake case
public enum BytecodeInstructionType: UInt8, CustomStringConvertible {
	
	// TODO: add documentation with stack before/after execution
	
	case pushConst = 0
	case add = 1
	case sub = 2
	case mul = 3
	case div = 4
	case pow = 5
	
	case and = 6
	case or = 7
	case not = 8
	
	/// Equal
	case eq = 9
	/// Not equals
	case neq = 10
	
	case ifTrue = 11
	case ifFalse = 12

	/// Compare less than or equal
	case cmple = 13
	
	/// Compare less than
	case cmplt = 14

	
	case goto = 15
	
	case registerStore = 16
	case registerClear = 17
	case registerLoad = 18
	
	case invokeFunc = 19
	
	public var opCode: UInt8 {
		return self.rawValue
	}
	
	public var description: String {
		
		switch self {
		
		case .pushConst:
			return "push_const"
		
		case .add:
			return "add"
			
		case .sub:
			return "sub"
			
		case .mul:
			return "mul"
			
		case .div:
			return "div"
			
		case .pow:
			return "pow"
			
		case .and:
			return "and"
			
		case .or:
			return "or"
			
		case .not:
			return "not"
			
		case .eq:
			return "eq"
			
		case .neq:
			return "neq"
		
		case .ifTrue:
			return "if_true"
		
		case .ifFalse:
			return "if_false"
			
		case .cmple:
			return "cmple"
		
		case .cmplt:
			return "cmplt"
			
		case .goto:
			return "goto"
			
		case .registerStore:
			return "reg_store"
			
		case .registerClear:
			return "reg_clear"
			
		case .registerLoad:
			return "reg_load"
			
		case .invokeFunc:
			return "invoke_func"
			
		}
		
	}
	
}
