//
//  ParseError.swift
//  Lioness
//
//  Created by Louis D'hauwe on 22/10/2016.
//  Copyright © 2016 Silver Fox. All rights reserved.
//

import Foundation

public enum ParseError: Error {
	case unexpectedToken
	case undefinedOperator(String)
	
	case expectedCharacter(Character)
	case expectedExpression
	case expectedArgumentList
	case expectedFunctionName
	
	case internalInconsistencyOccurred
	
}
