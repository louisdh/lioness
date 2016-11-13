//
//  Token.swift
//  Lioness
//
//  Created by Louis D'hauwe on 11/10/2016.
//  Copyright © 2016 Silver Fox. All rights reserved.
//

import Foundation

public enum TokenType {
	
	/// Token which has no effect on program, such as white space
	case ignoreableToken
	
	case identifier(String)
	case number(Double)
	
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
	case `for`
	case `if`
	case `else`
	case function
	case `true`
	case `false`
	case `continue`
	
	// Fallback
	case other(String)
	
	var uniqueDescription: String {
		return "\(self)"
	}
	
}

func ==(lhs: TokenType, rhs: TokenType) -> Bool {
	return lhs.uniqueDescription == rhs.uniqueDescription
}

public struct Token: CustomStringConvertible {
	
	/// The token's type
	let type: TokenType
	
	/// The range of the token in the original source code
	let range: Range<String.Index>
	
	public var description: String {
		return "\(type)"
	}
	
}
