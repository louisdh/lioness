//
//  ReturnNode.swift
//  Lioness
//
//  Created by Louis D'hauwe on 17/12/2016.
//  Copyright © 2016 Silver Fox. All rights reserved.
//

import Foundation

public class ReturnNode: ASTNode {
	
	public override func compile(with ctx: BytecodeCompiler) throws -> BytecodeBody {
		
		let label = ctx.nextIndexLabel()
		
		guard let cleanupLabel = ctx.peekFunctionExit() else {
			throw CompileError.unexpectedCommand
		}
		
		return [BytecodeInstruction(label: label, type: .goto, arguments: [cleanupLabel], comment: "return")]
		
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
