//
//  WhileStatementNode.swift
//  Lioness
//
//  Created by Louis D'hauwe on 21/10/2016.
//  Copyright © 2016 Silver Fox. All rights reserved.
//

import Foundation

public class WhileStatementNode: LoopNode {
	
	public let condition: ASTNode
	public let body: BodyNode
	
	public init(condition: ASTNode, body: BodyNode) throws {
		
		guard condition.isValidConditionNode else {
			throw CompileError.unexpectedCommand
		}
		
		self.condition = condition
		self.body = body
	}
	
	override func compileLoop(with ctx: BytecodeCompiler, scopeStart: String) throws -> [BytecodeInstruction] {
		
		var bytecode = [BytecodeInstruction]()
		
		let loopScopeStart = ctx.peekNextIndexLabel()
		ctx.pushLoopContinue(loopScopeStart)
		
		let conditionInstruction = try condition.compile(with: ctx)
		bytecode.append(contentsOf: conditionInstruction)
		
		let ifeqLabel = ctx.nextIndexLabel()
		
		let bodyBytecode = try body.compile(with: ctx)
		
		
		let goToEndLabel = ctx.nextIndexLabel()
		
		let peekNextLabel = ctx.peekNextIndexLabel()
		let ifeq = BytecodeInstruction(label: ifeqLabel, type: .ifFalse, arguments: [peekNextLabel])
		
		bytecode.append(ifeq)
		bytecode.append(contentsOf: bodyBytecode)
		
		let goToStart = BytecodeInstruction(label: goToEndLabel, type: .goto, arguments: [scopeStart])
		bytecode.append(goToStart)
		
		guard let _ = ctx.popLoopContinue() else {
			throw CompileError.unexpectedCommand
		}
		
		return bytecode
	}
	
	public override var description: String {
		
		var str = "WhileStatementNode(condition: \(condition), body: "

		str += "\n    \(body.description)"
		
		str += ")"

		return str
	}
	
	public override var nodeDescription: String? {
		return "while"
	}
	
	public override var childNodes: [ASTChildNode] {
		var children = [ASTChildNode]()
		
		let conditionChildNode = ASTChildNode(connectionToParent: "condition", isConnectionConditional: false, node: condition)
		children.append(conditionChildNode)
		
		let bodyChildNode = ASTChildNode(connectionToParent: nil, isConnectionConditional: true, node: body)

		children.append(bodyChildNode)
		
		return children
	}
	
}
