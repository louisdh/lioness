//
//  ReturnNode.swift
//  Lioness
//
//  Created by Louis D'hauwe on 17/12/2016.
//  Copyright © 2016 - 2017 Silver Fox. All rights reserved.
//

import Foundation

public class ReturnNode: ASTNode {
	
	public let value: ASTNode?
	
	init(value: ASTNode? = nil) {
		self.value = value
	}
	
	public override func compile(with ctx: BytecodeCompiler) throws -> BytecodeBody {
		
		var bytecode = BytecodeBody()

		if let value = value {
			
			let compiledValue = try value.compile(with: ctx)
			
			bytecode.append(contentsOf: compiledValue)
			
		}
		
		
		let label = ctx.nextIndexLabel()
		
		guard let cleanupLabel = ctx.peekFunctionExit() else {
			throw CompileError.unexpectedCommand
		}
		
		let exitInstruction = BytecodeInstruction(label: label, type: .goto, arguments: [cleanupLabel], comment: "return")
	
		bytecode.append(exitInstruction)
		
		return bytecode
	}
	
	public override var description: String {
		return "ReturnNode"
	}
	
	public override var nodeDescription: String? {
		return "return"
	}
	
	public override var childNodes: [ASTChildNode] {
		return []
	}
	
}
