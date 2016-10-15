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
	public let rhs: ASTNode
	
	public init(op: String, lhs: ASTNode, rhs: ASTNode) {
		self.op = op
		self.lhs = lhs
		self.rhs = rhs
	}
	
	public override func compile(_ ctx: BytecodeCompiler) throws -> [BytecodeInstruction] {
		
		let l = try lhs.compile(ctx)
		let r = try rhs.compile(ctx)
		
		var bytecode = [BytecodeInstruction]()
		
		bytecode.append(contentsOf: l)
		bytecode.append(contentsOf: r)
		
		let label = ctx.nextIndexLabel()
		
		var opTypes: [String : BytecodeInstructionType]
		
		opTypes = ["+" : .add,
		           "-" : .sub,
		           "*" : .mul,
		           "/" : .div,
		           "^" : .pow]
		
		guard let type = opTypes[op] else {
			throw CompileError.unexpectedCommand
		}
		
		let operation = BytecodeInstruction(label: label, type: type)
		
		bytecode.append(operation)
		
		return bytecode
		
	}
	
	public override var description: String {
		return "BinaryOpNode(\(op), lhs: \(lhs), rhs: \(rhs))"
	}
	
}

//public func ==(lhs: BinaryOpNode, rhs: BinaryOpNode) -> Bool {
//	return lhs.op == rhs.op && lhs.lhs == rhs.lhs && lhs.rhs == rhs.rhs
//}
