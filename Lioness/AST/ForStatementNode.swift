//
//  ForStatementNode.swift
//  Lioness
//
//  Created by Louis D'hauwe on 13/11/2016.
//  Copyright © 2016 Silver Fox. All rights reserved.
//

import Foundation

public class ForStatementNode: ASTNode {

	public let assignment: AssignmentNode
	public let condition: ASTNode
	public let interval: ASTNode

	public let body: BodyNode
	
	public init(assignment: AssignmentNode, condition: ASTNode, interval: ASTNode, body: BodyNode) throws {
		
		guard condition.isValidConditionNode else {
			throw CompileError.unexpectedCommand
		}
		
		guard interval is AssignmentNode else {
			throw CompileError.unexpectedCommand
		}
		
		self.assignment = assignment
		self.condition = condition
		self.interval = interval

		self.body = body
	}
	
	public override func compile(with ctx: BytecodeCompiler) throws -> [BytecodeInstruction] {
		
		var bytecode = [BytecodeInstruction]()
		
		// enter new scope for iterator variable
		ctx.enterNewScope()
		
		let assignInstructions = try assignment.compile(with: ctx)
		bytecode.append(contentsOf: assignInstructions)

		let firstLabelOfBody = ctx.peekNextIndexLabel()
		
		ctx.pushScopeStartStack(firstLabelOfBody)
		
		let conditionInstruction = try condition.compile(with: ctx)
		bytecode.append(contentsOf: conditionInstruction)
		
		let ifeqLabel = ctx.nextIndexLabel()
		
		let bodyBytecode = try body.compile(with: ctx)
		
		let intervalInstructions = try interval.compile(with: ctx)

		let goToEndLabel = ctx.nextIndexLabel()
		
		
		let peekNextLabel = ctx.peekNextIndexLabel()
		let ifeq = BytecodeInstruction(label: ifeqLabel, type: .ifFalse, arguments: [peekNextLabel])
		
		bytecode.append(ifeq)
		bytecode.append(contentsOf: bodyBytecode)
		bytecode.append(contentsOf: intervalInstructions)
		
		
		let goToStart = BytecodeInstruction(label: goToEndLabel, type: .goto, arguments: [firstLabelOfBody])
		bytecode.append(goToStart)
		
		guard let _ = ctx.popScopeStartStack() else {
			throw CompileError.unexpectedCommand
		}
		
		let cleanupInstructions = try ctx.leaveCurrentScope()
		bytecode.append(contentsOf: cleanupInstructions)
		
		return bytecode
		
	}
	
	public override var description: String {
		
		var str = "ForStatementNode(assignment: \(assignment), "

		str += "condition: \n\(condition.description)"

		str += "interval: \n\(interval.description)"

		str += "body: \n\(body.description)"
		
		str += ")"
		
		return str
	}
	
	public override var nodeDescription: String? {
		return "for"
	}
	
	public override var childNodes: [ASTChildNode] {
		var children = [ASTChildNode]()
		
		let assignmentChildNode = ASTChildNode(connectionToParent: "assignment", isConnectionConditional: false, node: assignment)
		children.append(assignmentChildNode)
		
		let conditionChildNode = ASTChildNode(connectionToParent: "condition", isConnectionConditional: false, node: condition)
		children.append(conditionChildNode)
		
		let intervalChildNode = ASTChildNode(connectionToParent: "interval", isConnectionConditional: false, node: interval)
		children.append(intervalChildNode)
		
		let bodyChildNode = ASTChildNode(connectionToParent: nil, isConnectionConditional: true, node: body)
		children.append(bodyChildNode)
		
		return children
	}
	
}
