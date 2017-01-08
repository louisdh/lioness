//
//  ContinueNode.swift
//  Lioness
//
//  Created by Louis D'hauwe on 22/10/2016.
//  Copyright © 2016 - 2017 Silver Fox. All rights reserved.
//

import Foundation

public class ContinueNode: ASTNode {
	
	public func compile(with ctx: BytecodeCompiler, in parent: ASTNode?) throws -> BytecodeBody {
		
		let label = ctx.nextIndexLabel()
		
		guard let continueLabel = ctx.peekLoopContinue() else {
			throw CompileError.unexpectedCommand
		}
		
		return [BytecodeInstruction(label: label, type: .goto, arguments: [continueLabel], comment: "continue")]
		
	}
	
	public var childNodes: [ASTNode] {
		return []
	}
	
	public var description: String {
		return "ContinueNode"
	}
	
	public var nodeDescription: String? {
		return "continue"
	}
	
	public var descriptionChildNodes: [ASTChildNode] {
		return []
	}
	
}
