//
//  Parser.swift
//  Lioness
//
//  Created by Louis D'hauwe on 04/10/2016.
//  Copyright © 2016 Silver Fox. All rights reserved.
//

import Foundation

enum ParseError: Error {
	case unexpectedToken
	case undefinedOperator(String)
	
	case expectedCharacter(Character)
	case expectedExpression
	case expectedArgumentList
	case expectedFunctionName
}

class Parser {
	
	fileprivate let tokens: [Token]
	fileprivate var index = 0
	
	init(tokens: [Token]) {
		self.tokens = tokens
	}
	
	// MARK: -
	// MARK: Public
	
	func parse() throws -> [ASTNode] {
		
		index = 0
		
		var nodes = [ASTNode]()
		
		while index < tokens.count {
			
			switch peekCurrentToken() {
				case .function:
					let node = try parseFunction()
					nodes.append(node)
					
				default:
					let expr = try parseExpression()
					nodes.append(expr)
			}
			
		}
		
		return nodes
	}

	// MARK: -
	// MARK: Private
	
	fileprivate func peekCurrentToken() -> Token {
		return tokens[index]
	}
	
	@discardableResult
	fileprivate func popCurrentToken() -> Token {
		
		let t = tokens[index]
		index += 1
		
		return t
	}
	
	fileprivate func parseNumber() throws -> ASTNode {
		
		guard case let Token.number(value) = popCurrentToken() else {
			throw ParseError.unexpectedToken
		}
		
		return NumberNode(value: value)
	}
	
	fileprivate func parseExpression() throws -> ASTNode {
		let node = try parsePrimary()
		return try parseBinaryOp(node)
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
		
		guard case Token.parensOpen = peekCurrentToken() else {
			return VariableNode(name: name)
		}
		
		popCurrentToken()
		
		var arguments = [ASTNode]()
		
		if case Token.parensClose = peekCurrentToken() {
		
		} else {
			
			while true {
				
				let argument = try parseExpression()
				arguments.append(argument)
				
				if case Token.parensClose = peekCurrentToken() {
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
		
		switch peekCurrentToken() {
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
	
	fileprivate let operatorPrecedence: [String: Int] = [
		"+": 20,
		"-": 20,
		"*": 40,
		"/": 40,
		"^": 60
	]
	
	fileprivate func getCurrentTokenPrecedence() throws -> Int {
		guard index < tokens.count else {
			return -1
		}
		
		guard case let Token.other(op) = peekCurrentToken() else {
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
		while case let Token.identifier(name) = peekCurrentToken() {
			popCurrentToken()
			argumentNames.append(name)
			
			if case Token.parensClose = peekCurrentToken() {
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

			let expr = try parseExpression()
			body.append(expr)

			if case Token.curlyClose = peekCurrentToken() {
				break
			}
			
		}
		
		guard case Token.curlyClose = popCurrentToken() else {
			throw ParseError.expectedCharacter("}")
		}
		
		return FunctionNode(prototype: prototype, body: body)
	}
	
	fileprivate func parseTopLevelExpr() throws -> FunctionNode {
		let prototype = PrototypeNode(name: "", argumentNames: [])
		
		let expr1 = try parseExpression()
		let body = [expr1]

		return FunctionNode(prototype: prototype, body: body)
	}
	
}
