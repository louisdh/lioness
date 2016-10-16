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
		
		
		
		var bytecode = [BytecodeInstruction]()
		
		let label = ctx.nextIndexLabel()
		
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
		           "<=": .cmple]
		
		guard let type = opTypes[op] else {
			throw CompileError.unexpectedCommand
		}
		
		if op == ">" || op == ">=" {
			
			// flip l and r

			let r = try lhs.compile(ctx)
			let l = try rhs.compile(ctx)
			
			bytecode.append(contentsOf: l)
			bytecode.append(contentsOf: r)
			
		} else {
			
			let l = try lhs.compile(ctx)
			let r = try rhs.compile(ctx)
			
			bytecode.append(contentsOf: l)
			bytecode.append(contentsOf: r)
			
		}
		
		let operation = BytecodeInstruction(label: label, type: type)
		
		bytecode.append(operation)
		
		return bytecode
		
	}
	
	public override var description: String {
		return "BinaryOpNode(\(op), lhs: \(lhs), rhs: \(rhs))"
	}
	
}
