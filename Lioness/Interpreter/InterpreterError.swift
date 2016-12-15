//
//  InterpreterError.swift
//  Lioness
//
//  Created by Louis D'hauwe on 15/12/2016.
//  Copyright © 2016 Silver Fox. All rights reserved.
//

import Foundation

/// Interpreter Error
public enum InterpreterError: Error {
	/// Unexpected argument
	case unexpectedArgument
	
	/// Illegal stack operation
	case illegalStackOperation
	
	/// Stack overflow occured
	case stackOverflow
}
