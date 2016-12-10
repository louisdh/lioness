//
//  ContinueNode.swift
//  Lioness
//
//  Created by Louis D'hauwe on 22/10/2016.
//  Copyright © 2016 Silver Fox. All rights reserved.
//

import Foundation

public class ContinueNode: ASTNode {
	
	public override func compile(with ctx: BytecodeCompiler) throws -> [BytecodeInstruction] {
		
		let label = ctx.nextIndexLabel()
		
		guard let continueLabel = ctx.peekLoopContinue() else {
			throw CompileError.unexpectedCommand
		}
		
		return [BytecodeInstruction(label: label, type: .goto, arguments: [continueLabel], comment: "continue")]
		
	}
	
	public override var description: String {
		return "ContinueNode"
	}
	
	public override var nodeDescription: String? {
		return "continue"
	}
	
	public override var childNodes: [ASTChildNode] {
		return []
	}
	
}
