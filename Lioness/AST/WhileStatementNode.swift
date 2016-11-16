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
	public let body: BodyNode
	
	public init(condition: ASTNode, body: BodyNode) throws {
		
		guard condition.isValidConditionNode else {
			throw CompileError.unexpectedCommand
		}
		
		self.condition = condition
		self.body = body
	}
	
	public override func compile(with ctx: BytecodeCompiler) throws -> [BytecodeInstruction] {
		
		var bytecode = [BytecodeInstruction]()
		
		let firstLabelOfBody = ctx.peekNextIndexLabel()
		
		ctx.pushScopeStartStack(firstLabelOfBody)
		
		let conditionInstruction = try condition.compile(with: ctx)
		bytecode.append(contentsOf: conditionInstruction)
		
		let ifeqLabel = ctx.nextIndexLabel()
		
		var bodyBytecode = [BytecodeInstruction]()
		
		let bodyInstructions = try body.compile(with: ctx)
		bodyBytecode.append(contentsOf: bodyInstructions)
		
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
		
		let conditionChildNode = ASTChildNode(connectionToParent: "condition", isConnectionConditional: true, node: condition)
		children.append(conditionChildNode)
		
		let bodyChildNode = ASTChildNode(connectionToParent: nil, isConnectionConditional: false, node: body)

		children.append(bodyChildNode)
		
		return children
	}
	
}
