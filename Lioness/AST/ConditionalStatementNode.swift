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
	public let elseBody: [ASTNode]?

	public init(condition: ASTNode, body: [ASTNode], elseBody: [ASTNode]? = nil) {
		self.condition = condition
		self.body = body
		self.elseBody = elseBody
	}
	
	public override func compile(_ ctx: BytecodeCompiler) throws -> [BytecodeInstruction] {
		
		var bytecode = [BytecodeInstruction]()

		let conditionInstruction = try condition.compile(ctx)
		bytecode.append(contentsOf: conditionInstruction)

		let ifeqLabel = ctx.nextIndexLabel()
		

		var bodyBytecode = [BytecodeInstruction]()

		var elseBodyBytecode = [BytecodeInstruction]()

		for a in body {
			let instructions = try a.compile(ctx)
			bodyBytecode.append(contentsOf: instructions)
		}
		
		let goToEndLabel = ctx.nextIndexLabel()

		
		let peekNextLabel = ctx.peekNextIndexLabel()
		let ifeq = BytecodeInstruction(label: ifeqLabel, type: .ifFalse, arguments: [peekNextLabel])
		bytecode.append(ifeq)
		
		if let elseBody = elseBody {
			
			for a in elseBody {
				let instructions = try a.compile(ctx)
				elseBodyBytecode.append(contentsOf: instructions)
			}
			
		}

		bytecode.append(contentsOf: bodyBytecode)

		let goToEnd = BytecodeInstruction(label: goToEndLabel, type: .goto, arguments: [ctx.peekNextIndexLabel()])
		bytecode.append(goToEnd)

		bytecode.append(contentsOf: elseBodyBytecode)
	
		return bytecode
		
	}
	
	public override var description: String {
		
		var str = "ConditionalStatementNode(condition: \(condition), body: ["
		
		for e in body {
			str += "\n    \(e.description)"
		}
		
		if let elseBody = elseBody {

			str += "], elseBody: ["
			
			for e in elseBody {
				str += "\n    \(e.description)"
			}
			
			str += "\n])"
			
		} else {
			
			str += "\n])"

		}
		
		return str
	}
	
}
