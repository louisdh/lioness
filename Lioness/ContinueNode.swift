//
//  ContinueNode.swift
//  Lioness
//
//  Created by Louis D'hauwe on 22/10/2016.
//  Copyright © 2016 Silver Fox. All rights reserved.
//

import Foundation

public class ContinueNode: ASTNode {
	
	public override func compile(_ ctx: BytecodeCompiler) throws -> [BytecodeInstruction] {
		
		let label = ctx.nextIndexLabel()
		
		guard let startOfScope = ctx.peekScopeStartStack() else {
			throw CompileError.unexpectedCommand
		}
		
		return [BytecodeInstruction(label: label, type: .goto, arguments: [startOfScope])]
		
	}
	
	public override var description: String {
		return "ContinueNode"
	}
	
	public override var nodeDescription: String? {
		return "continue"
	}
	
	public override var childNodes: [(String?, ASTNode)] {
		return []
	}
	
}
