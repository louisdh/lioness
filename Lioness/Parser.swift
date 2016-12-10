//
//  Parser.swift
//  Lioness
//
//  Created by Louis D'hauwe on 04/10/2016.
//  Copyright © 2016 Silver Fox. All rights reserved.
//

import Foundation

public class Parser {
	
	fileprivate let tokens: [Token]
	
	/// Token index
	fileprivate var index = 0
	
	public init(tokens: [Token]) {
		self.tokens = tokens
	}
	
	// MARK: - Public
	
	public func parse() throws -> [ASTNode] {
		
		index = 0
		
		var nodes = [ASTNode]()
		
		while index < tokens.count {
			
			guard let currentToken = peekCurrentToken() else {
				throw error(.internalInconsistencyOccurred)
			}
			
			switch currentToken.type {
				
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

	// MARK: - Private
	
	// TODO: Refactor operators and their precedence
	
	fileprivate let operatorPrecedence: [String : Int] = [
		"+": 20,
		"-": 20,
		"*": 40,
		"/": 40,
		"^": 60
	]
	
	fileprivate func operatorString(for tokenType: TokenType) -> String? {

		if case let .other(op) = tokenType {
			return op
		}
		
		if case .comparatorEqual = tokenType {
			return "=="
		}
		
		if case .notEqual = tokenType {
			return "!="
		}
		
		if case .comparatorLessThan = tokenType {
			return "<"
		}
		
		if case .comparatorLessThanEqual = tokenType {
			return "<="
		}
		
		if case .comparatorGreaterThan = tokenType {
			return ">"
		}
		
		if case .comparatorGreaterThanEqual = tokenType {
			return ">="
		}
		
		return nil
	}
	
	fileprivate func operatorPrecedence(for tokenType: TokenType) -> Int? {
		
		if case let .other(op) = tokenType {
			return operatorPrecedence[op]
		}

		if case .comparatorEqual = tokenType {
			return 10
		}
		
		if case .notEqual = tokenType {
			return 10
		}
		
		if case .comparatorLessThan = tokenType {
			return 10
		}
		
		if case .comparatorLessThanEqual = tokenType {
			return 10
		}
		
		if case .comparatorGreaterThan = tokenType {
			return 10
		}
		
		if case .comparatorGreaterThanEqual = tokenType {
			return 10
		}
		
		return nil
	}
	
	fileprivate func booleanOperatorString(for tokenType: TokenType) -> String? {
	
		if case .booleanOr = tokenType {
			return "||"
		}
		
		if case .booleanAnd = tokenType {
			return "&&"
		}
		
		if case .booleanNot = tokenType {
			return "!"
		}
		
		if case .comparatorEqual = tokenType {
			return "=="
		}
		
		if case .notEqual = tokenType {
			return "!="
		}
		
		return nil
		
	}
	
	fileprivate func booleanOperatorPrecedence(for tokenType: TokenType) -> Int? {
		
		if case .booleanOr = tokenType {
			return 20
		}
		
		if case .booleanAnd = tokenType {
			return 40
		}
		
		if case .booleanNot = tokenType {
			return 60
		}
		
		if case .comparatorEqual = tokenType {
			return 10
		}
		
		if case .notEqual = tokenType {
			return 10
		}
		
		return nil
	}
	
	/// Get operator for token (e.g. '+=' returns '+')
	fileprivate func getOperator(for tokenType: TokenType) -> String? {

		if case .shortHandAdd = tokenType {
			return "+"
		}
		
		if case .shortHandSub = tokenType {
			return "-"
		}
		
		if case .shortHandMul = tokenType {
			return "*"
		}
		
		if case .shortHandDiv = tokenType {
			return "/"
		}
		
		if case .shortHandPow = tokenType {
			return "^"
		}

		return nil
	}

	// MARK: - Token peek & pop

	fileprivate func peekPreviousToken() -> Token? {
		return peekToken(offset: -1)
	}
	
	fileprivate func peekCurrentToken() -> Token? {
		return peekToken(offset: 0)
	}
	
	/// Look ahead 1 token
	fileprivate func peekNextToken() -> Token? {
		return peekToken(offset: 1)
	}
	
	/// Look ahead
	fileprivate func peekToken(offset: Int) -> Token? {
		return tokens[safe: index + offset]
	}
	
	@discardableResult
	fileprivate func popCurrentToken() -> Token {
		
		let t = tokens[index]
		index += 1
		
		return t
	}
	
	@discardableResult
	fileprivate func popCurrentToken(andExpect type: TokenType, _ tokenString: String? = nil) throws  -> Token {
		
		let currentToken = popCurrentToken()
		
		guard type == currentToken.type else {
			
			if let tokenString = tokenString {
				throw error(.expectedCharacterButFound(char: tokenString, token: currentToken))
			} else {
				throw error(.unexpectedToken)
			}
			
		}
		
		return currentToken

	}
	
	// MARK: - Parsing look ahead
	
	/// Look ahead to check if boolean operator should be parsed
	fileprivate func shouldParseBooleanOp() -> Bool {

		var i = 0
		while let tokenAhead = peekToken(offset: i) {
			
			if case .true = tokenAhead.type {
				return true
			}
			
			if case .false = tokenAhead.type {
				return true
			}
			
			if let _ = booleanOperatorString(for: tokenAhead.type) {
				// Don't assume boolean op if op is also possible for binary ops
				if operatorPrecedence(for: tokenAhead.type) == nil {
					return true
				}
			}
			
			i += 1

			if case .parensClose = tokenAhead.type {
				continue
			}
			
			if case .parensOpen = tokenAhead.type {
				continue
			}
			
			return false
		}
		
		return false
		
	}

	/// Look ahead to check if assignment should be parsed
	fileprivate func shouldParseAssignment() -> Bool {

		guard let currentToken = peekCurrentToken(), case .identifier = currentToken.type else {
			return false
		}
		
		guard let nextToken = peekNextToken() else {
			return false
		}
		
		guard case .equals = nextToken.type else {
			return false
		}
		
		return true
		
	}
	
	// MARK: - Parsing

	fileprivate func parseAssignment() throws -> AssignmentNode {
		
		guard case let .identifier(variable) = popCurrentToken().type else {
			throw error(.unexpectedToken)
		}
		
		try popCurrentToken(andExpect: .equals, "=")
		
		let expr = try parseExpression()
		
		let assign = AssignmentNode(variable: VariableNode(name: variable), value: expr)

		return assign
	}
	
	fileprivate func parseNumber() throws -> ASTNode {
		
		guard case let .number(value) = popCurrentToken().type else {
			throw error(.unexpectedToken)
		}
		
		return NumberNode(value: value)
	}
	
	/// Expression can be a binary/bool op
	fileprivate func parseExpression() throws -> ASTNode {
		
		let node = try parsePrimary()
		
		// Handles short hand operators (e.g. "+=")
		if let currentToken = peekCurrentToken(), let op = getOperator(for: currentToken.type) {
			
			guard let variable = node as? VariableNode else {
				throw error(.expectedVariable)
			}
			
			popCurrentToken()

			let node1 = try parsePrimary()
			let expr = try parseBinaryOp(node1)
			
			let operation: BinaryOpNode
			
			do {
				operation = try BinaryOpNode(op: op, lhs: variable, rhs: expr)
			} catch {
				throw self.error(.illegalBinaryOperation, token: currentToken)
			}
			
			let assignment = AssignmentNode(variable: variable, value: operation)
			
			return assignment
		
		}
		
		if shouldParseBooleanOp() {
			
			let expr = try parseBooleanOp(node)
			return expr
			
		}
		
		let expr = try parseBinaryOp(node)
		
		return expr

	}
	
	fileprivate func parseParensExpr() throws -> ASTNode {
		
		try popCurrentToken(andExpect: .parensOpen, "(")
		
		let expr = try parseExpression()
		
		try popCurrentToken(andExpect: .parensClose, ")")

		return expr
	}
	
	fileprivate func parseNotOperation() throws -> ASTNode {
		
		try popCurrentToken(andExpect: .booleanNot, "!")
		
		guard let currentToken = peekCurrentToken() else {
			throw error(.unexpectedToken)
		}
		
		if case .parensOpen = currentToken.type {
			
			let expr = try parseParensExpr()
			
			return BooleanOpNode(op: "!", lhs: expr)
			
		} else {
			
			let lhs: ASTNode
			
			switch currentToken.type {
				
				case .identifier:
					lhs = try parseIdentifier()
				
				case .number:
					lhs = try parseNumber()
				
				case .true, .false:
					lhs = try parseRawBoolean()
				
				default:
					throw error(.unexpectedToken)

			}
			
			return BooleanOpNode(op: "!", lhs: lhs)
			
		}

	}
	
	fileprivate func parseIdentifier() throws -> ASTNode {
		
		guard case let .identifier(name) = popCurrentToken().type else {
			throw error(.unexpectedToken)
		}

		guard let currentToken = peekCurrentToken(), case .parensOpen = currentToken.type else {
			return VariableNode(name: name)
		}
		
		popCurrentToken()
		
		var arguments = [ASTNode]()
		
		if let currentToken = peekCurrentToken(), case .parensClose = currentToken.type {
		
		} else {
			
			while true {
				
				let argument = try parseExpression()
				arguments.append(argument)

				if let currentToken = peekCurrentToken(), case .parensClose = currentToken.type {
					break
				}
				
				guard case .comma = popCurrentToken().type else {
					throw error(.expectedArgumentList)
				}
				
			}
			
		}
		
		popCurrentToken()
		return CallNode(callee: name, arguments: arguments)
	}
	
	/// Primary can be seen as the start of an operation 
	/// (e.g. boolean operation), where this function returns the first term
	fileprivate func parsePrimary() throws -> ASTNode {
		
		guard let currentToken = peekCurrentToken() else {
			throw error(.unexpectedToken)
		}
		
		switch currentToken.type {
			case .identifier:
				return try parseIdentifier()
		
			case .number:
				return try parseNumber()

			case .true, .false:
				return try parseRawBoolean()

			case .booleanNot:
				return try parseNotOperation()
			
			case .parensOpen:
				return try parseParensExpr()
			
			case .if:
				return try parseIfStatement()
			
			case .continue:
				return try parseContinue()
			
			case .break:
				return try parseBreak()
			
			case .while:
				return try parseWhileStatement()
			
			case .repeat:
				return try parseRepeatWhileStatement()
			
			case .for:
				return try parseForStatement()
			
			case .do:
				return try parseDoStatement()
			
			default:
				throw error(.expectedExpression, token: currentToken)
		}
		
	}
	
	fileprivate func parseContinue() throws -> ASTNode {

		try popCurrentToken(andExpect: .continue)

		return ContinueNode()
	}
	
	fileprivate func parseBreak() throws -> ASTNode {
		
		try popCurrentToken(andExpect: .break)
		
		return BreakLoopNode()
	}
	
	fileprivate func parseIfStatement() throws -> ASTNode {
		
		try popCurrentToken(andExpect: .if)
		
		let condition = try parseExpression()
		
		let body = try parseBodyWithCurlies()
		
		if let currentToken = peekCurrentToken(), case .else = currentToken.type {
			
			try popCurrentToken(andExpect: .else)
			
			if let currentToken = peekCurrentToken(), case .if = currentToken.type {
				
				let ifStatement = try parseIfStatement()
				let elseBody = BodyNode(nodes: [ifStatement])
				
				return ConditionalStatementNode(condition: condition, body: body, elseBody: elseBody)
				
			}

			let elseBody = try parseBodyWithCurlies()

			return ConditionalStatementNode(condition: condition, body: body, elseBody: elseBody)

		} else {
			
			return ConditionalStatementNode(condition: condition, body: body)

		}
		
	}
	
	fileprivate func parseDoStatement() throws -> ASTNode {
		
		let doToken = try popCurrentToken(andExpect: .do)

		let amount = try parseExpression()
		
		try popCurrentToken(andExpect: .times)
		
		let body = try parseBodyWithCurlies()
		
		let doStatement: DoStatementNode
		
		do {
			
			doStatement = try DoStatementNode(amount: amount, body: body)
			
		} catch {
			
			throw self.error(.illegalStatement, token: doToken)
			
		}
		
		return doStatement
	}
	
	fileprivate func parseForStatement() throws -> ASTNode {
		
		let forToken = try popCurrentToken(andExpect: .for)
		
		let assignment = try parseAssignment()
		
		try popCurrentToken(andExpect: .comma, ",")
		
		let condition = try parseExpression()
		
		try popCurrentToken(andExpect: .comma, ",")

		let interval = try parseExpression()
		
		let body = try parseBodyWithCurlies()
		
		let forStatement: ForStatementNode
		
		do {
			
			forStatement = try ForStatementNode(assignment: assignment, condition: condition, interval: interval, body: body)
		
		} catch {
			
			throw self.error(.illegalStatement, token: forToken)

		}
		
		return forStatement
	}
	
	fileprivate func parseWhileStatement() throws -> ASTNode {
		
		let whileToken = try popCurrentToken(andExpect: .while)
		
		let condition = try parseExpression()
		
		let body = try parseBodyWithCurlies()
		
		let whileStatement: WhileStatementNode
		
		do {
			whileStatement = try WhileStatementNode(condition: condition, body: body)
		} catch {
			throw self.error(.illegalStatement, token: whileToken)
		}

		return whileStatement
	}
	
	fileprivate func parseRepeatWhileStatement() throws -> ASTNode {

		try popCurrentToken(andExpect: .repeat)

		let body = try parseBodyWithCurlies()

		let whileToken = try popCurrentToken(andExpect: .while)
		
		let condition = try parseExpression()
		
		let whileStatement: RepeatWhileStatementNode
		
		do {
			whileStatement = try RepeatWhileStatementNode(condition: condition, body: body)
		} catch {
			throw self.error(.illegalStatement, token: whileToken)
		}
		
		return whileStatement
	}
	
	fileprivate func parseBodyWithCurlies() throws -> BodyNode {

		try popCurrentToken(andExpect: .curlyOpen, "{")
		
		let body = try parseBody()
		
		try popCurrentToken(andExpect: .curlyClose, "}")

		return body
	}
	
	/// Expects opened curly brace, will exit when closing curly brace found
	fileprivate func parseBody() throws -> BodyNode {
		
		var nodes = [ASTNode]()
		
		while index < tokens.count {
			
			if let currentToken = peekCurrentToken(), case .curlyClose = currentToken.type {
				break
			}
			
			if shouldParseAssignment() {
				
				let assign = try parseAssignment()
				nodes.append(assign)
				
			} else {
				
				let expr = try parseExpression()
				nodes.append(expr)
				
			}			
			
		}
		
		return BodyNode(nodes: nodes)
		
	}
	
	/// Parse "true" or "false"
	fileprivate func parseRawBoolean() throws -> ASTNode {
		
		guard let currentToken = peekCurrentToken() else {
			throw error(.unexpectedToken)
		}
		
		if case .true = currentToken.type {
			popCurrentToken()
			return BooleanNode(bool: true)
		}
		
		if case .false = currentToken.type {
			popCurrentToken()
			return BooleanNode(bool: false)
		}
		
		throw error(.unexpectedToken)
	}
	
	fileprivate func getCurrentTokenBinaryOpPrecedence() -> Int {
		
		guard index < tokens.count else {
			return -1
		}
		
		guard let currentToken = peekCurrentToken() else {
			return -1
		}
		
		guard let precedence = operatorPrecedence(for: currentToken.type) else {
			return -1
		}
		
		return precedence
	}
	
	fileprivate func getCurrentTokenBooleanOpPrecedence() -> Int {
		
		guard index < tokens.count else {
			return -1
		}
		
		guard let currentToken = peekCurrentToken() else {
			return -1
		}
		
		guard let precedence = booleanOperatorPrecedence(for: currentToken.type) else {
			return -1
		}
		
		return precedence
	}
	
	/// Recursive
	fileprivate func parseBinaryOp(_ node: ASTNode, exprPrecedence: Int = 0) throws -> ASTNode {
		
		var lhs = node
		
		while true {
			
			let tokenPrecedence = getCurrentTokenBinaryOpPrecedence()
			if tokenPrecedence < exprPrecedence {
				return lhs
			}
			
			let token = popCurrentToken()
			
			guard let op = operatorString(for: token.type) else {
				throw error(.unexpectedToken)
			}
			
			var rhs = try parsePrimary()
			let nextPrecedence = getCurrentTokenBinaryOpPrecedence()
			
			if tokenPrecedence < nextPrecedence {
				rhs = try parseBinaryOp(rhs, exprPrecedence: tokenPrecedence + 1)
			}
			
			do {
				lhs = try BinaryOpNode(op: op, lhs: lhs, rhs: rhs)
			} catch {
				throw self.error(.illegalBinaryOperation, token: token)
			}
			
		}
		
	}
	
	/// Recursive
	fileprivate func parseBooleanOp(_ node: ASTNode, exprPrecedence: Int = 0) throws -> ASTNode {
		
		var lhs = node
		
		while true {
			
			let tokenPrecedence = getCurrentTokenBooleanOpPrecedence()
			if tokenPrecedence < exprPrecedence {
				
				return lhs
			}
			
			guard let op = booleanOperatorString(for: popCurrentToken().type) else {
				throw error(.unexpectedToken)
			}
			
			var rhs = try parsePrimary()
			let nextPrecedence = getCurrentTokenBooleanOpPrecedence()
			
			if tokenPrecedence < nextPrecedence {
				rhs = try parseBooleanOp(rhs, exprPrecedence: tokenPrecedence + 1)
			}
			
			lhs = BooleanOpNode(op: op, lhs: lhs, rhs: rhs)
			
		}
		
	}
	
	fileprivate func parsePrototype() throws -> PrototypeNode {
		
		guard case let .identifier(name) = popCurrentToken().type else {
			throw error(.expectedFunctionName)
		}
		
		try popCurrentToken(andExpect: .parensOpen, "(")

		var argumentNames = [String]()
		while let currentToken = peekCurrentToken(), case let .identifier(name) = currentToken.type {
			popCurrentToken()
			argumentNames.append(name)
			
			if let currentToken = peekCurrentToken(), case .parensClose = currentToken.type {
				break
			}
			
			guard case .comma = popCurrentToken().type else {
				throw error(.expectedArgumentList)
			}
		}
		
		try popCurrentToken(andExpect: .parensClose, ")")

		try popCurrentToken(andExpect: .curlyOpen, "{")
		
		return PrototypeNode(name: name, argumentNames: argumentNames)
	}
	
	fileprivate func parseFunction() throws -> FunctionNode {
		
		popCurrentToken()
		
		let prototype = try parsePrototype()
		
		let body = try parseBody()
		
		try popCurrentToken(andExpect: .curlyClose, "}")

		
		return FunctionNode(prototype: prototype, body: body)
	}
	
	// MARK: -
	
	fileprivate func error(_ type: ParseErrorType, token: Token? = nil) -> ParseError {
		
		let token = token ?? peekCurrentToken() ?? peekPreviousToken()
		let range = token?.range
		
		return ParseError(type: type, range: range)
	}

}
