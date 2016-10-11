//
//  VariableNode.swift
//  Lioness
//
//  Created by Louis D'hauwe on 09/10/2016.
//  Copyright © 2016 Silver Fox. All rights reserved.
//

import Foundation

public class VariableNode: ASTNode {
	
	public let name: String
	
	init(name: String) {
		self.name = name
	}
	
	public override func compile(_ ctx: BytecodeCompiler) throws -> [BytecodeInstruction] {
		
		var bytecode = [BytecodeInstruction]()

		let load = BytecodeInstruction(label: ctx.nextIndexLabel(), type: .registerLoad, arguments: [name])
		
		bytecode.append(load)
		
		return bytecode
		
	}
	
	public override var description: String {
		return "VariableNode(\(name))"
	}
	
}

public func ==(lhs: VariableNode, rhs: VariableNode) -> Bool {
	return lhs === rhs
}
