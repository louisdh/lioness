//
//  LoopNode.swift
//  Lioness
//
//  Created by Louis D'hauwe on 09/12/2016.
//  Copyright © 2016 Silver Fox. All rights reserved.
//

import Foundation

public class LoopNode: ASTNode {
	
	public override func compile(with ctx: BytecodeCompiler) throws -> [BytecodeInstruction] {
		
		var bytecode = [BytecodeInstruction]()

		let loopScopeStart = ctx.peekNextIndexLabel()
		
		ctx.pushLoopScopeStart(loopScopeStart)
		
		let compiledLoop = try compileLoop(with: ctx, scopeStart: loopScopeStart)
		
		bytecode.append(contentsOf: compiledLoop)
		
		guard let _ = ctx.popLoopScopeStart() else {
			throw CompileError.unexpectedCommand
		}
		
		return bytecode
	}
	
	func compileLoop(with ctx: BytecodeCompiler, scopeStart: String) throws -> [BytecodeInstruction] {
		return []
	}
	
}
