//
//  AssignmentNode.swift
//  Lioness
//
//  Created by Louis D'hauwe on 10/10/2016.
//  Copyright © 2016 Silver Fox. All rights reserved.
//

import Foundation

public class AssignmentNode: ASTNode {
	
	public let variable: VariableNode
	public let value: ASTNode
	
	init(variable: VariableNode, value: ASTNode) {
		self.variable = variable
		self.value = value
	}
	
	public override func compile(_ ctx: BytecodeCompiler) throws -> [BytecodeInstruction] {
		
		let v = try value.compile(ctx)
		
		var bytecode = [BytecodeInstruction]()

		bytecode.append(contentsOf: v)
		
		let label = ctx.nextIndexLabel()
		let push = BytecodeInstruction(label: label, type: .registerStore, arguments: [variable.name])
		
		bytecode.append(push)

		return bytecode
		
	}
	
	public override var description: String {
		return "\(variable.description) = \(value.description)"
	}
	
}
