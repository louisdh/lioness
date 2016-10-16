//
//  ConditionalStatementNode.swift
//  Lioness
//
//  Created by Louis D'hauwe on 16/10/2016.
//  Copyright © 2016 Silver Fox. All rights reserved.
//

import Foundation

public class ConditionalStatementNode: ASTNode {
	
	public let condition: ASTNode
	public let body: [ASTNode]
	
	public init(condition: ASTNode, body: [ASTNode]) {
		self.condition = condition
		self.body = body
	}
	
	public override func compile(_ ctx: BytecodeCompiler) throws -> [BytecodeInstruction] {
		
		var bytecode = [BytecodeInstruction]()
		
		let conditionInstruction = try condition.compile(ctx)
		bytecode.append(contentsOf: conditionInstruction)

		let ifeqLabel = ctx.nextIndexLabel()
		
		var bodyBytecode = [BytecodeInstruction]()
		for a in body {
			let instructions = try a.compile(ctx)
			bodyBytecode.append(contentsOf: instructions)
		}
		
		let peekNextLabel = ctx.peekNextIndexLabel()
		let ifeq = BytecodeInstruction(label: ifeqLabel, type: .ifFalse, arguments: [peekNextLabel])
		bytecode.append(ifeq)

		bytecode.append(contentsOf: bodyBytecode)

		return bytecode
		
	}
	
	public override var description: String {
		
		var str = "ConditionalStatementNode(condition: \(condition), body: ["
		
		for e in body {
			str += "\n    \(e.description)"
		}
		
		return str + "\n])"
	}
	
}
