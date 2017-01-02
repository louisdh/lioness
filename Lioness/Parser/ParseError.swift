//
//  ParseError.swift
//  Lioness
//
//  Created by Louis D'hauwe on 22/10/2016.
//  Copyright © 2016 - 2017 Silver Fox. All rights reserved.
//

import Foundation

public enum ParseErrorType {
	case unexpectedToken
	case undefinedOperator(String)
	
	case expectedCharacter(String)
	case expectedCharacterButFound(char: String, token: Token)
	case expectedExpression
	case expectedArgumentList
	case expectedFunctionName
	case expectedVariable
	
	case illegalBinaryOperation

	case illegalStatement

	case internalInconsistencyOccurred
	
	func description(atLine line: Int? = nil) -> String {

		if let line = line {

			switch self {
			case .unexpectedToken:
				return "Unexpected token on line \(line)"
				
			case .undefinedOperator(let op):
				return "Undefined operator (\"\(op)\") on line \(line)"
				
			case .expectedCharacter(let c):
				return "Expected character \"\(c)\" on line \(line)"
			
			case .expectedCharacterButFound(let c1, let c2):
				return "Expected character \"\(c1)\" but found \"\(c2)\" on line \(line)"
				
			case .expectedExpression:
				return "Expected expression on line \(line)"
				
			case .expectedArgumentList:
				return "Expected argument list on line \(line)"
				
			case .expectedFunctionName:
				return "Expected function name on line \(line)"
				
			case .internalInconsistencyOccurred:
				return "Internal inconsistency occured on line \(line)"
				
			case .illegalBinaryOperation:
				return "Illegal binary operation on line \(line)"
			
			case .illegalStatement:
				return "Illegal statement on line \(line)"
				
			case .expectedVariable:
				return "Expected variable on line \(line)"
				
			}
		
		}
		
		switch self {
		case .unexpectedToken:
			return "Unexpected token"
			
		case .undefinedOperator(let op):
			return "Undefined operator (\"\(op)\")"
			
		case .expectedCharacter(let c):
			return "Expected character \"\(c)\""
			
		case .expectedCharacterButFound(let c1, let c2):
			return "Expected character \"\(c1)\" but found \"\(c2)\""
			
		case .expectedExpression:
			return "Expected expression"
			
		case .expectedArgumentList:
			return "Expected argument list"
			
		case .expectedFunctionName:
			return "Expected function name"
			
		case .internalInconsistencyOccurred:
			return "Internal inconsistency occured"
		
		case .illegalBinaryOperation:
			return "Illegal binary operation"
		
		case .illegalStatement:
			return "Illegal statement"
			
		case .expectedVariable:
			return "Expected variable)"
			
		}
	}
}

public struct ParseError: Error, CustomStringConvertible {

	/// The parse error type
	let type: ParseErrorType
	
	/// The range of the token in the original source code
	let range: Range<String.Index>?

	init(type: ParseErrorType, range: Range<String.Index>? = nil) {
		self.type = type
		self.range = range
	}
	
	func description(inSource source: String) -> String {
		
		guard let startIndex = range?.lowerBound else {
			return type.description()
		}

		let lineNumber = source.lineNumber(of: startIndex)
		
		return type.description(atLine: lineNumber)
	}
	
	public var description: String {
		return "\(type)"
	}
	
}

extension String {

	func lineNumber(of index: String.Index) -> Int {
		
		let i = self.distance(from: self.startIndex, to: index)

		let newLineIndices = self.indices(of: "\n").map { (index) -> Int in
			return self.distance(from: self.startIndex, to: index)
		}
		
		var lineNumber = 1
		
		for newLineIndex in newLineIndices {
			
			if i > newLineIndex {
				
				lineNumber += 1
				
			} else {
				
				break
				
			}
			
		}
		
		return lineNumber
	}
	
	func indices(of string: String, options: String.CompareOptions = .literal) -> [String.Index] {
		var result: [String.Index] = []
		var start = startIndex
		
		while let range = range(of: string, options: options, range: start..<endIndex) {
			result.append(range.lowerBound)
			start = range.upperBound
		}
		
		return result
	}
	
}
