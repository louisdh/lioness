//
//  Parser.swift
//  Lioness
//
//  Created by Louis D'hauwe on 04/10/2016.
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
}

public class Parser {
	
	fileprivate let tokens: [Token]
	
	/// Token index
	fileprivate var index = 0
	
	public init(tokens: [Token]) {
		self.tokens = tokens
	}
	
	// MARK: -
	// MARK: Public
	
	public func parse() throws -> [ASTNode] {
		
		index = 0
		
		var nodes = [ASTNode]()
		
		while index < tokens.count {
			
			guard let currentToken = peekCurrentToken() else {
				continue
			}
			
			switch currentToken {
				
				case .function:
					let node = try parseFunction()
					nodes.append(node)
				
				default:
					
					if shouldParseAssignment() {
						
						let assign = try parseAssignment()
						nodes.append(assign)
						
					} else {
						
						let expr = try parseExpression()
						nodes.append(expr)
					
					}
				
			}
			
		}
		
		return nodes
	}

	// MARK: -
	// MARK: Private
	
	fileprivate let operatorPrecedence: [String : Int] = [
		"+": 20,
		"-": 20,
		"*": 40,
		"/": 40,
		"^": 60
	]

	/// Get operator for token (e.g. '+=' returns '+')
	fileprivate func getOperator(for token: Token) -> String? {

		if case .shortHandAdd = token {
			return "+"
		}
		
		if case .shortHandSub = token {
			return "-"
		}
		
		if case .shortHandMul = token {
			return "*"
		}
		
		if case .shortHandDiv = token {
			return "/"
		}
		
		if case .shortHandPow = token {
			return "^"
		}

		return nil
	}

	// MARK: Tokens

	fileprivate func peekCurrentToken() -> Token? {
		return tokens[safe: index]
	}
	
	fileprivate func peekNextToken() -> Token? {
		return tokens[safe: index + 1]
	}
	
	@discardableResult
	fileprivate func popCurrentToken() -> Token {
		
		let t = tokens[index]
		index += 1
		
		return t
	}
	
	// MARK: Parsing

	fileprivate func shouldParseAssignment() -> Bool {

		guard let currentToken = peekCurrentToken(), case Token.identifier = currentToken else {
			return false
		}
		
		guard let nextToken = peekNextToken() else {
			return false
		}
		
		guard case Token.equals = nextToken else {
			return false
		}
		
		return true
		
	}
	
	fileprivate func parseAssignment() throws -> AssignmentNode {
		
		guard case let Token.identifier(variable) = popCurrentToken() else {
			throw ParseError.unexpectedToken
		}
		
		guard case Token.equals = popCurrentToken() else {
			throw ParseError.expectedCharacter("=")
		}
		
		let exp = try parseExpression()
		
		let assign = AssignmentNode(variable: VariableNode(name: variable), value: exp)

		return assign
	}
	
	fileprivate func parseNumber() throws -> ASTNode {
		
		guard case let Token.number(value) = popCurrentToken() else {
			throw ParseError.unexpectedToken
		}
		
		return NumberNode(value: value)
	}
	
	fileprivate func parseExpression() throws -> ASTNode {
		
		let node = try parsePrimary()
		
		// Handles short hand operators (e.g. "+=")
		if let currentToken = peekCurrentToken(), let op = getOperator(for: currentToken)  {
			
			popCurrentToken()

			let node1 = try parsePrimary()
			let expr = try parseBinaryOp(node1)
			
			guard let variable = node as? VariableNode else {
				throw ParseError.unexpectedToken
			}
			
			let operation = BinaryOpNode(op: op, lhs: variable, rhs: expr)
			
			let assignment = AssignmentNode(variable: variable, value: operation)
			
			return assignment
		
		}
		
		
		let expr = try parseBinaryOp(node)

		return expr
	}
	
	fileprivate func parseParens() throws -> ASTNode {
		
		guard case Token.parensOpen = popCurrentToken() else {
			throw ParseError.expectedCharacter("(")
		}
		
		let exp = try parseExpression()
		
		guard case Token.parensClose = popCurrentToken() else {
			throw ParseError.expectedCharacter(")")
		}
		
		return exp
	}
	
	fileprivate func parseIdentifier() throws -> ASTNode {
		
		guard case let Token.identifier(name) = popCurrentToken() else {
			throw ParseError.unexpectedToken
		}

		guard let currentToken = peekCurrentToken(), case Token.parensOpen = currentToken else {
			return VariableNode(name: name)
		}
		
		popCurrentToken()
		
		var arguments = [ASTNode]()
		
		if let currentToken = peekCurrentToken(), case Token.parensClose = currentToken {
		
		} else {
			
			while true {
				
				let argument = try parseExpression()
				arguments.append(argument)

				if let currentToken = peekCurrentToken(), case Token.parensClose = currentToken {
					break
				}
				
				guard case Token.comma = popCurrentToken() else {
					throw ParseError.expectedArgumentList
				}
				
			}
			
		}
		
		popCurrentToken()
		return CallNode(callee: name, arguments: arguments)
	}
	
	fileprivate func parsePrimary() throws -> ASTNode {
		
		guard let currentToken = peekCurrentToken() else {
			throw ParseError.unexpectedToken
		}
		
		switch currentToken {
			case .identifier:
				return try parseIdentifier()
			case .number:
				return try parseNumber()
			case .parensOpen:
				return try parseParens()
			default:
				throw ParseError.expectedExpression
		}
		
	}
	
	fileprivate func getCurrentTokenPrecedence() throws -> Int {
		
		guard index < tokens.count else {
			return -1
		}
		
		guard let currentToken = peekCurrentToken(), case let Token.other(op) = currentToken else {
			return -1
		}
		
		guard let precedence = operatorPrecedence[op] else {
			throw ParseError.undefinedOperator(op)
		}
		
		return precedence
	}
	
	fileprivate func parseBinaryOp(_ node: ASTNode, exprPrecedence: Int = 0) throws -> ASTNode {
		
		var lhs = node

		while true {
			
			let tokenPrecedence = try getCurrentTokenPrecedence()
			if tokenPrecedence < exprPrecedence {
				
				return lhs
			}
			
			guard case let Token.other(op) = popCurrentToken() else {
				throw ParseError.unexpectedToken
			}
			
			var rhs = try parsePrimary()
			let nextPrecedence = try getCurrentTokenPrecedence()
			
			if tokenPrecedence < nextPrecedence {
				rhs = try parseBinaryOp(rhs, exprPrecedence: tokenPrecedence + 1)
			}
			
			lhs = BinaryOpNode(op: op, lhs: lhs, rhs: rhs)
			
		}
		
	}
	
	fileprivate func parsePrototype() throws -> PrototypeNode {
		
		guard case let Token.identifier(name) = popCurrentToken() else {
			throw ParseError.expectedFunctionName
		}
		
		guard case Token.parensOpen = popCurrentToken() else {
			throw ParseError.expectedCharacter("(")
		}
		
		var argumentNames = [String]()
		while let currentToken = peekCurrentToken(), case let Token.identifier(name) = currentToken {
			popCurrentToken()
			argumentNames.append(name)
			
			if let currentToken = peekCurrentToken(), case Token.parensClose = currentToken {
				break
			}
			
			guard case Token.comma = popCurrentToken() else {
				throw ParseError.expectedArgumentList
			}
		}
		
		// remove ")"
		popCurrentToken()
		
		guard case Token.curlyOpen = popCurrentToken() else {
			throw ParseError.expectedCharacter("{")
		}
		
		return PrototypeNode(name: name, argumentNames: argumentNames)
	}
	
	fileprivate func parseFunction() throws -> FunctionNode {
		
		popCurrentToken()
		
		let prototype = try parsePrototype()
		
		
		var body = [ASTNode]()

		while index < tokens.count {
			
			if shouldParseAssignment() {
				
				let assign = try parseAssignment()
				body.append(assign)
				
			} else {
				
				let expr = try parseExpression()
				body.append(expr)
				
			}
			
			if let currentToken = peekCurrentToken(), case Token.curlyClose = currentToken {
				break
			}
			
		}
		
		guard case Token.curlyClose = popCurrentToken() else {
			throw ParseError.expectedCharacter("}")
		}
		
		return FunctionNode(prototype: prototype, body: body)
	}

}
