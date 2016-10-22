//
//  WhileStatementNode.swift
//  Lioness
//
//  Created by Louis D'hauwe on 21/10/2016.
//  Copyright © 2016 Silver Fox. All rights reserved.
//

import Foundation

public class WhileStatementNode: ASTNode {
	
	public let condition: ASTNode
	public let body: [ASTNode]
	
	public init(condition: ASTNode, body: [ASTNode], elseBody: [ASTNode]? = nil) {
		self.condition = condition
		self.body = body
	}
	
	public override func compile(_ ctx: BytecodeCompiler) throws -> [BytecodeInstruction] {
		
		var bytecode = [BytecodeInstruction]()
		
		let firstLabelOfBody = ctx.peekNextIndexLabel()
		
		ctx.pushScopeStartStack(firstLabelOfBody)
		
		let conditionInstruction = try condition.compile(ctx)
		bytecode.append(contentsOf: conditionInstruction)
		
		let ifeqLabel = ctx.nextIndexLabel()
		
		var bodyBytecode = [BytecodeInstruction]()
		
		for a in body {
			let instructions = try a.compile(ctx)
			bodyBytecode.append(contentsOf: instructions)
		}
		
		let goToEndLabel = ctx.nextIndexLabel()
		
		
		let peekNextLabel = ctx.peekNextIndexLabel()
		let ifeq = BytecodeInstruction(label: ifeqLabel, type: .ifFalse, arguments: [peekNextLabel])
		bytecode.append(ifeq)
	
		bytecode.append(contentsOf: bodyBytecode)
		
		
		let goToStart = BytecodeInstruction(label: goToEndLabel, type: .goto, arguments: [firstLabelOfBody])
		bytecode.append(goToStart)
		
		guard let _ = ctx.popScopeStartStack() else {
			throw CompileError.unexpectedCommand
		}

		return bytecode
		
	}
	
	public override var description: String {
		
		var str = "WhileStatementNode(condition: \(condition), body: ["
		
		for e in body {
			str += "\n    \(e.description)"
		}
		
		str += "\n])"

		return str
	}
	
}
