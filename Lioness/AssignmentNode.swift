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
	
	public func compile(with ctx: BytecodeCompiler, in parent: ASTNode?) throws -> BytecodeBody {
		
		let v = try value.compile(with: ctx, in: self)
		
		var bytecode = BytecodeBody()

		bytecode.append(contentsOf: v)
		
		let label = ctx.nextIndexLabel()
		let (varReg, isNew) = ctx.getRegister(for: variable.name)
		
		let type: BytecodeInstructionType = isNew ? .registerStore : .registerUpdate
		
		let instruction = BytecodeInstruction(label: label, type: type, arguments: [varReg], comment: "\(variable.name)")
		
		bytecode.append(instruction)

		return bytecode
		
	}
	
	public var childNodes: [ASTNode] {
		return [variable, value]
	}
	
	public var description: String {
		return "\(variable.description) = \(value.description)"
	}
	
	public var nodeDescription: String? {
		return "="
	}
	
	public var descriptionChildNodes: [ASTChildNode] {
		let lhs = ASTChildNode(connectionToParent: "lhs", node: variable)
		let rhs = ASTChildNode(connectionToParent: "rhs", node: value)
		
		return [lhs, rhs]
	}
	
}
