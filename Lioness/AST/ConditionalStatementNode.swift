//
//  ConditionalStatementNode.swift
//  Lioness
//
//  Created by Louis D'hauwe on 16/10/2016.
//  Copyright © 2016 - 2017 Silver Fox. All rights reserved.
//

import Foundation

public class ConditionalStatementNode: ASTNode {
	
	public let condition: ASTNode
	public let body: BodyNode
	public let elseBody: BodyNode?

	public init(condition: ASTNode, body: BodyNode, elseBody: BodyNode? = nil) {
		self.condition = condition
		self.body = body
		self.elseBody = elseBody
	}
	
	public override func compile(with ctx: BytecodeCompiler) throws -> BytecodeBody {
		
		var bytecode = BytecodeBody()

		let conditionInstruction = try condition.compile(with: ctx)
		bytecode.append(contentsOf: conditionInstruction)

		let ifeqLabel = ctx.nextIndexLabel()
		

		var bodyBytecode = BytecodeBody()

		var elseBodyBytecode = BytecodeBody()

		let bodyInstructions = try body.compile(with: ctx)
		bodyBytecode.append(contentsOf: bodyInstructions)
		
		let goToEndLabel = ctx.nextIndexLabel()

		
		let peekNextLabel = ctx.peekNextIndexLabel()
		let ifeq = BytecodeInstruction(label: ifeqLabel, type: .ifFalse, arguments: [peekNextLabel])
		bytecode.append(ifeq)
		
		if let elseBody = elseBody {
			
			let instructions = try elseBody.compile(with: ctx)
			elseBodyBytecode.append(contentsOf: instructions)
			
		}

		bytecode.append(contentsOf: bodyBytecode)

		if let elseBody = elseBody, elseBody.nodes.count > 0 {
			let goToEnd = BytecodeInstruction(label: goToEndLabel, type: .goto, arguments: [ctx.peekNextIndexLabel()])
			bytecode.append(goToEnd)
		}
		
		bytecode.append(contentsOf: elseBodyBytecode)
	
		return bytecode
		
	}
	
	public override var description: String {
		
		var str = "ConditionalStatementNode(condition: \(condition), body: ["
		
		str += "\n    \(body.description)"
		
		if let elseBody = elseBody {

			str += ", elseBody: "
			
			str += "\n    \(elseBody.description)"

			str += "\n)"
			
		} else {
			
			str += "\n])"

		}
		
		return str
	}
	
	public override var nodeDescription: String? {
		return "if"
	}
	
	public override var childNodes: [ASTChildNode] {
		var children = [ASTChildNode]()
		
		let conditionChildNode = ASTChildNode(connectionToParent: "condition", isConnectionConditional: false, node: condition)
		children.append(conditionChildNode)
		
		
		let ifChildNode = ASTChildNode(connectionToParent: "if", isConnectionConditional: true, node: body)
		children.append(ifChildNode)

		if let elseBody = elseBody {
			let elseChildNode = ASTChildNode(connectionToParent: "else", isConnectionConditional: true, node: elseBody)
			children.append(elseChildNode)
		}
		
		return children
	}
	
}
