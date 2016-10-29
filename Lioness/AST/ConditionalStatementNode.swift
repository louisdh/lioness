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
	public let body: BodyNode
	public let elseBody: BodyNode?

	public init(condition: ASTNode, body: BodyNode, elseBody: BodyNode? = nil) {
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

		let bodyInstructions = try body.compile(ctx)
		bodyBytecode.append(contentsOf: bodyInstructions)
		
		let goToEndLabel = ctx.nextIndexLabel()

		
		let peekNextLabel = ctx.peekNextIndexLabel()
		let ifeq = BytecodeInstruction(label: ifeqLabel, type: .ifFalse, arguments: [peekNextLabel])
		bytecode.append(ifeq)
		
		if let elseBody = elseBody {
			
			let instructions = try elseBody.compile(ctx)
			elseBodyBytecode.append(contentsOf: instructions)
			
		}

		bytecode.append(contentsOf: bodyBytecode)

		let goToEnd = BytecodeInstruction(label: goToEndLabel, type: .goto, arguments: [ctx.peekNextIndexLabel()])
		bytecode.append(goToEnd)

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
	
	public override var childNodes: [(String?, ASTNode)] {
		var children = [(String?, ASTNode)]()
		
		children.append(("condition", condition))
		
		children.append(("if", body))

		if let elseBody = elseBody {
			children.append(("else", elseBody))
		}
		
		return children
	}
	
}
