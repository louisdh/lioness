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
	
	public init(name: String) {
		self.name = name
	}
	
	public override func compile(with ctx: BytecodeCompiler) throws -> BytecodeBody {
		
		var bytecode = BytecodeBody()

		let varReg = ctx.getRegister(for: name)
		let load = BytecodeInstruction(label: ctx.nextIndexLabel(), type: .registerLoad, arguments: [varReg], comment: name)
		
		bytecode.append(load)
		
		return bytecode
		
	}
	
	public override var description: String {
		return "VariableNode(\(name))"
	}
	
	public override var nodeDescription: String? {
		return "\(name)"
	}
	
	public override var childNodes: [ASTChildNode] {
		return []
	}
	
}
