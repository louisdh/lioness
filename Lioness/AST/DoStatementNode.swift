//
//  DoStatementNode.swift
//  Lioness
//
//  Created by Louis D'hauwe on 13/11/2016.
//  Copyright © 2016 Silver Fox. All rights reserved.
//

import Foundation

public class DoStatementNode: ASTNode {
	
	public let amount: ASTNode
	
	public let body: BodyNode
	
	/// Do statement
	///
	/// - Parameters:
	///   - amount: Amount should either be a NumberNode or VariableNode
	///   - body: BodyNode to execute `amount` of times
	/// - Throws: CompileError
	public init(amount: ASTNode, body: BodyNode) throws {
		
		guard amount is NumberNode || amount is VariableNode || amount is BinaryOpNode else {
			throw CompileError.unexpectedCommand
		}

		if let numberNode = amount as? NumberNode {
			if numberNode.value <= 0.0 {
				throw CompileError.unexpectedCommand
			}
		}
		
		self.amount = amount
		self.body = body
	}
	
	public override func compile(with ctx: BytecodeCompiler) throws -> [BytecodeInstruction] {
		
		var bytecode = [BytecodeInstruction]()
		
		// enter new scope for iterator variable
		ctx.enterNewScope()
		
		let doStatementInstructions = try doStatementCompiled(with: ctx)
		bytecode.append(contentsOf: doStatementInstructions)
		
		let cleanupInstructions = try ctx.leaveCurrentScope()
		bytecode.append(contentsOf: cleanupInstructions)
		
		return bytecode
		
	}
	
	// MARK: -
	
	fileprivate func doStatementCompiled(with ctx: BytecodeCompiler) throws -> [BytecodeInstruction] {
		
		var bytecode = [BytecodeInstruction]()

		let varReg = ctx.getNewInternalRegisterAndStoreInScope()
		
		let assignInstructions = try assignmentInstructions(with: ctx, and: varReg)
		bytecode.append(contentsOf: assignInstructions)
		
		let firstLabelOfBody = ctx.peekNextIndexLabel()
		
		ctx.pushScopeStartStack(firstLabelOfBody)
		
		let conditionInstruction = try conditionInstructions(with: ctx, and: varReg)
		bytecode.append(contentsOf: conditionInstruction)
		
		let ifeqLabel = ctx.nextIndexLabel()
		
		let bodyBytecode = try body.compile(with: ctx)
		
		let intervalInstructions = try decrementInstructions(with: ctx, and: varReg)
		
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
		
		return bytecode
	}
	
	fileprivate func assignmentInstructions(with ctx: BytecodeCompiler, and regName: String) throws -> [BytecodeInstruction] {
		
		let v = try amount.compile(with: ctx)
		
		var bytecode = [BytecodeInstruction]()
		
		bytecode.append(contentsOf: v)
		
		let label = ctx.nextIndexLabel()
		let instruction = BytecodeInstruction(label: label, type: .registerStore, arguments: [regName], comment: "do repeat iterator")
		
		bytecode.append(instruction)
		
		return bytecode
		
	}
	
	fileprivate func conditionInstructions(with ctx: BytecodeCompiler, and regName: String) throws -> [BytecodeInstruction] {
		
		let varNode = InternalVariableNode(register: regName)
		let conditionNode = try BinaryOpNode(op: ">", lhs: varNode, rhs: NumberNode(value: 0.0))
		
		let bytecode = try conditionNode.compile(with: ctx)
		
		return bytecode
		
	}
	
	fileprivate func decrementInstructions(with ctx: BytecodeCompiler, and regName: String) throws -> [BytecodeInstruction] {
		
		let varNode = InternalVariableNode(register: regName)
		let decrementNode = try BinaryOpNode(op: "-", lhs: varNode, rhs: NumberNode(value: 1.0))
		
		let v = try decrementNode.compile(with: ctx)
		
		var bytecode = [BytecodeInstruction]()
		
		bytecode.append(contentsOf: v)
		
		let label = ctx.nextIndexLabel()
		let instruction = BytecodeInstruction(label: label, type: .registerStore, arguments: [regName])
		
		bytecode.append(instruction)
		
		return bytecode
		
	}
	
	// MARK: -
	
	public override var description: String {
		
		var str = "DoStatementNode(amount: \(amount), "
		
		str += "body: \n\(body.description)"
		
		str += ")"
		
		return str
	}
	
	public override var nodeDescription: String? {
		return "do"
	}
	
	public override var childNodes: [ASTChildNode] {
		var children = [ASTChildNode]()

		let amountChildNode = ASTChildNode(connectionToParent: "amount", isConnectionConditional: false, node: amount)
		children.append(amountChildNode)
		
		let bodyChildNode = ASTChildNode(connectionToParent: nil, isConnectionConditional: true, node: body)
		children.append(bodyChildNode)
		
		return children
	}
	
}
