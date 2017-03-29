//
//  BinaryOpNode.swift
//  Lioness
//
//  Created by Louis D'hauwe on 09/10/2016.
//  Copyright © 2016 - 2017 Silver Fox. All rights reserved.
//

import Foundation

public class BinaryOpNode: ASTNode {

	public let op: String
	public let lhs: ASTNode

	/// Can be nil, e.g. for 'not' operation
	public let rhs: ASTNode?

	public init(op: String, lhs: ASTNode, rhs: ASTNode? = nil) throws {
		self.op = op

		guard lhs.isValidBinaryOpNode else {
			throw CompileError.unexpectedCommand
		}

		if let rhs = rhs {
			guard rhs.isValidBinaryOpNode else {
				throw CompileError.unexpectedCommand
			}
		}

		self.lhs = lhs
		self.rhs = rhs
	}

	public func compile(with ctx: BytecodeCompiler, in parent: ASTNode?) throws -> BytecodeBody {

		var bytecode = BytecodeBody()

		var opTypes: [String : BytecodeInstructionType]

		opTypes = ["+": .add,
		           "-": .sub,
		           "*": .mul,
		           "/": .div,
		           "^": .pow,
		           "==": .eq,
		           "!=": .neq,
		           ">": .cmplt,
		           "<": .cmplt,
		           ">=": .cmple,
		           "<=": .cmple,
		           "&&": .and,
		           "||": .or,
		           "!": .not]

		guard let type = opTypes[op] else {
			throw CompileError.unexpectedBinaryOperator
		}

		if op == ">" || op == ">=" {

			// flip l and r

			let r = try rhs?.compile(with: ctx, in: self)
			let l = try lhs.compile(with: ctx, in: self)

			if let r = r {
				bytecode.append(contentsOf: r)
			}

			bytecode.append(contentsOf: l)

		} else {

			let l = try lhs.compile(with: ctx, in: self)
			let r = try rhs?.compile(with: ctx, in: self)

			bytecode.append(contentsOf: l)

			if let r = r {
				bytecode.append(contentsOf: r)
			}

		}

		let label = ctx.nextIndexLabel()

		// FIXME: comment "op" is wrong for ">" and ">="
		let operation = BytecodeInstruction(label: label, type: type, comment: op)

		bytecode.append(operation)

		return bytecode

	}

	public var childNodes: [ASTNode] {
		if let rhs = rhs {
			return [lhs, rhs]
		}

		return [lhs]
	}

	public var description: String {
		return "BinaryOpNode(\(op), lhs: \(lhs), rhs: \(String(describing: rhs)))"
	}

	public var nodeDescription: String? {
		return op
	}

	public var descriptionChildNodes: [ASTChildNode] {
		let l = ASTChildNode(connectionToParent: "lhs", node: lhs)

		if let rhs = rhs {
			let r = ASTChildNode(connectionToParent: "rhs", node: rhs)
			return [l, r]
		}

		return [l]
	}

}
