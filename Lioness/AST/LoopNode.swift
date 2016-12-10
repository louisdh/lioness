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
		
		ctx.enterNewScope()
		
		
		let skipExitInstrLabel = ctx.nextIndexLabel()

		let exitLoopInstrLabel = ctx.nextIndexLabel()
		
		ctx.pushLoopHeader(exitLoopInstrLabel)
		
		
		let loopScopeStart = ctx.peekNextIndexLabel()
		
		let compiledLoop = try compileLoop(with: ctx, scopeStart: loopScopeStart)
		
		
		let loopEndLabel = ctx.peekNextIndexLabel()
		
		let skipExitInstruction = BytecodeInstruction(label: skipExitInstrLabel, type: .goto, arguments: [loopScopeStart], comment: "skip exit instruction")
		bytecode.append(skipExitInstruction)
		
		
		let exitLoopInstruction = BytecodeInstruction(label: exitLoopInstrLabel, type: .goto, arguments: [loopEndLabel], comment: "exit loop")
		bytecode.append(exitLoopInstruction)
		
		
		bytecode.append(contentsOf: compiledLoop)
		
		let cleanupInstructions = try ctx.leaveCurrentScope()
		bytecode.append(contentsOf: cleanupInstructions)
		
		return bytecode
	}
	
	func compileLoop(with ctx: BytecodeCompiler, scopeStart: String) throws -> [BytecodeInstruction] {
		return []
	}
	
}
