//
//  AssignmentNode.swift
//  Lioness
//
//  Created by Louis D'hauwe on 10/10/2016.
//  Copyright © 2016 - 2017 Silver Fox. All rights reserved.
//

import Foundation

public class AssignmentNode: ASTNode {
	
	public let variable: VariableNode
	public let value: ASTNode
	
	public init(variable: VariableNode, value: ASTNode) {
		self.variable = variable
		self.value = value
	}
	
	public override func compile(with ctx: BytecodeCompiler) throws -> BytecodeBody {
		
		let v = try value.compile(with: ctx)
		
		var bytecode = BytecodeBody()

		bytecode.append(contentsOf: v)
		
		let label = ctx.nextIndexLabel()
		let varReg = ctx.getRegister(for: variable.name)
		let instruction = BytecodeInstruction(label: label, type: .registerStore, arguments: [varReg], comment: "\(variable.name)")
		
		bytecode.append(instruction)

		return bytecode
		
	}
	
	public override var description: String {
		return "\(variable.description) = \(value.description)"
	}
	
	public override var nodeDescription: String? {
		return "="
	}
	
	public override var childNodes: [ASTChildNode] {
		let lhs = ASTChildNode(connectionToParent: "lhs", node: variable)
		let rhs = ASTChildNode(connectionToParent: "rhs", node: value)
		
		return [lhs, rhs]
	}
	
}
