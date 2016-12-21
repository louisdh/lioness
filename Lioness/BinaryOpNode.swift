//
//  BinaryOpNode.swift
//  Lioness
//
//  Created by Louis D'hauwe on 09/10/2016.
//  Copyright © 2016 Silver Fox. All rights reserved.
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
	
	public override func compile(with ctx: BytecodeCompiler) throws -> BytecodeBody {
		
		var bytecode = BytecodeBody()
		
		var opTypes: [String : BytecodeInstructionType]
		
		opTypes = ["+" : .add,
		           "-" : .sub,
		           "*" : .mul,
		           "/" : .div,
		           "^" : .pow,
		           "==" : .eq,
		           "!=" : .neq,
		           ">": .cmplt,
		           "<": .cmplt,
		           ">=": .cmple,
		           "<=": .cmple,
		           "&&" : .and,
		           "||" : .or,
		           "!" : .not]
		
		guard let type = opTypes[op] else {
			throw CompileError.unexpectedBinaryOperator
		}
		
		if op == ">" || op == ">=" {
			
			// flip l and r

			let r = try rhs?.compile(with: ctx)
			let l = try lhs.compile(with: ctx)
			
			if let r = r {
				bytecode.append(contentsOf: r)
			}
			
			bytecode.append(contentsOf: l)
			
		} else {
			
			let l = try lhs.compile(with: ctx)
			let r = try rhs?.compile(with: ctx)
			
			bytecode.append(contentsOf: l)
			
			if let r = r {
				bytecode.append(contentsOf: r)
			}
			
		}
		
		let label = ctx.nextIndexLabel()
		let operation = BytecodeInstruction(label: label, type: type)
		
		bytecode.append(operation)
		
		return bytecode
		
	}
	
	public override var description: String {
		return "BinaryOpNode(\(op), lhs: \(lhs), rhs: \(rhs))"
	}
	
	public override var nodeDescription: String? {
		return op
	}
	
	public override var childNodes: [ASTChildNode] {
		let l = ASTChildNode(connectionToParent: "lhs", node: lhs)
		
		if let rhs = rhs {
			let r = ASTChildNode(connectionToParent: "rhs", node: rhs)
			return [l, r]
		}
		
		return [l]
	}
	
	
}
