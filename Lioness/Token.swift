//
//  Token.swift
//  Lioness
//
//  Created by Louis D'hauwe on 11/10/2016.
//  Copyright © 2016 Silver Fox. All rights reserved.
//

import Foundation

public enum Token {
	
	case identifier(String)
	case number(Float)
	
	case parensOpen
	case parensClose
	case curlyOpen
	case curlyClose
	case comma
	
	// Comparators
	case comparatorEqual
	case comparatorGreaterThan
	case comparatorLessThan
	case comparatorGreaterThanEqual
	case comparatorLessThanEqual
	
	case equals
	case notEqual
	
	// Boolean operators
	case booleanAnd
	case booleanOr
	case booleanNot
	
	// Short hand operators
	case shortHandAdd
	case shortHandSub
	case shortHandMul
	case shortHandDiv
	case shortHandPow
	
	// Keywords
	case `while`
	case `if`
	case function
	case `true`
	case `false`
	
	// Fallback
	case other(String)
	
}
