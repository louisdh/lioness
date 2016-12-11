//
//  InternalVariableNode.swift
//  Lioness
//
//  Created by Louis D'hauwe on 17/11/2016.
//  Copyright © 2016 Silver Fox. All rights reserved.
//

import Foundation

public class InternalVariableNode: ASTNode {
	
	public let register: String
	
	public init(register: String) {
		self.register = register
	}
	
	public override func compile(with ctx: BytecodeCompiler) throws -> BytecodeBody {
		
		var bytecode = BytecodeBody()
		
		let load = BytecodeInstruction(label: ctx.nextIndexLabel(), type: .registerLoad, arguments: [register])
		
		bytecode.append(load)
		
		return bytecode
		
	}
	
	public override var description: String {
		return "InternalVariableNode(\(register))"
	}
	
	public override var nodeDescription: String? {
		return "\(register)"
	}
	
	public override var childNodes: [ASTChildNode] {
		return []
	}
	
}
