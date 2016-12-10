//
//  BreakLoopNode.swift
//  Lioness
//
//  Created by Louis D'hauwe on 08/12/2016.
//  Copyright © 2016 Silver Fox. All rights reserved.
//

import Foundation

public class BreakLoopNode: ASTNode {
	
	public override func compile(with ctx: BytecodeCompiler) throws -> [BytecodeInstruction] {
		
		let label = ctx.nextIndexLabel()
		
		guard let breakLabel = ctx.peekLoopHeader() else {
			throw CompileError.unexpectedCommand
		}
		
		return [BytecodeInstruction(label: label, type: .goto, arguments: [breakLabel], comment: "break")]
		
	}
	
	public override var description: String {
		return "BreakLoopNode"
	}
	
	public override var nodeDescription: String? {
		return "break"
	}
	
	public override var childNodes: [ASTChildNode] {
		return []
	}
	
}
