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
	///   - body: BodyNode to do `amount` of times
	/// - Throws: CompileError
	public init(amount: ASTNode, body: BodyNode) throws {
		
		guard amount is NumberNode || amount is VariableNode else {
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
		
		let bytecode = [BytecodeInstruction]()
	
		// TODO: generate bytecode
	
		
		return bytecode
		
	}
	
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
