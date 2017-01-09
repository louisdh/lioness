//
//  FunctionNode.swift
//  Lioness
//
//  Created by Louis D'hauwe on 09/10/2016.
//  Copyright © 2016 - 2017 Silver Fox. All rights reserved.
//

import Foundation

public class FunctionNode: ASTNode {
	
	public let prototype: PrototypeNode
	public let body: BodyNode
	
	public init(prototype: PrototypeNode, body: BodyNode) {
		self.prototype = prototype
		self.body = body
	}
	
	public func compile(with ctx: BytecodeCompiler, in parent: ASTNode?) throws -> BytecodeBody {
		
		var bytecode = BytecodeBody()
		
		
		ctx.enterNewScope()
		
		
		let _ = ctx.nextIndexLabel()
		let functionId = ctx.getFunctionId(for: self)
		let exitId = try ctx.getExitScopeFunctionId(for: self)

		let headerInstruction = BytecodeFunctionHeader(id: functionId, name: prototype.name, arguments: prototype.argumentNames)
		
		
		bytecode.append(headerInstruction)

		
		let skipExitInstrLabel = ctx.nextIndexLabel()
		
		let cleanupFunctionCallInstrLabel = ctx.nextIndexLabel()

		let exitFunctionInstrLabel = ctx.nextIndexLabel()


		ctx.pushFunctionExit(cleanupFunctionCallInstrLabel)
		
				
		let compiledFunction = try compileFunction(with: ctx)
		
		
		let _ = ctx.nextIndexLabel()
		
		let exitHeaderInstruction = BytecodePrivateFunctionHeader(id: exitId, name: "cleanup_\(prototype.name)")
		
		ctx.popFunctionExit()
		
		ctx.addCleanupRegistersToCurrentScope()
		let cleanupInstructions = ctx.cleanupRegisterInstructions()
		try ctx.leaveCurrentScope()
		
		let _ = ctx.nextIndexLabel()
		
	

		let skipExitInstruction = BytecodeInstruction(label: skipExitInstrLabel, type: .skipPast, arguments: [exitFunctionInstrLabel], comment: "skip exit instruction")
		bytecode.append(skipExitInstruction)
		
		let invokeInstruction = BytecodeInstruction(label: cleanupFunctionCallInstrLabel, type: .invokeFunc, arguments: [exitId], comment: "cleanup_\(prototype.name)()")
		bytecode.append(invokeInstruction)
		
		let exitFunctionInstruction = BytecodeInstruction(label: exitFunctionInstrLabel, type: .exitFunc, arguments: [], comment: "exit function")
		bytecode.append(exitFunctionInstruction)
		
		
		bytecode.append(contentsOf: compiledFunction)
		
		
		// Cleanup
		
	
		
		bytecode.append(exitHeaderInstruction)
		bytecode.append(contentsOf: cleanupInstructions)

		bytecode.append(BytecodePrivateEnd())
		
		//
		
		
		
		let _ = ctx.nextIndexLabel()
		bytecode.append(BytecodeEnd())
		
		return bytecode

	}
	
	fileprivate func compileFunction(with ctx: BytecodeCompiler) throws -> BytecodeBody {
		
		var bytecode = BytecodeBody()
		
		for arg in prototype.argumentNames.reversed() {
			
			let label = ctx.nextIndexLabel()
			let (varReg, _) = ctx.getRegister(for: arg)
			let instruction = BytecodeInstruction(label: label, type: .registerStore, arguments: [varReg], comment: "\(arg)")
			
			bytecode.append(instruction)
			
		}
		
		bytecode.append(contentsOf: try body.compile(with: ctx, in: self))
		
		if !prototype.returns {
			let returnNode = ReturnNode()
			bytecode.append(contentsOf: try returnNode.compile(with: ctx, in: self))
		}
		
		return bytecode
		
	}
	
	public var childNodes: [ASTNode] {
		return [prototype, body]
	}
	
	public var description: String {
		
		var str = "FunctionNode(prototype: \(prototype), "
		
		str += "\n    \(body.description)"
		
		return str + ")"
	}
	
	public var nodeDescription: String? {
		return "Function"
	}
	
	public var descriptionChildNodes: [ASTChildNode] {
		var children = [ASTChildNode]()
		
		children.append(contentsOf: body.descriptionChildNodes)
		
		return children
	}
	
}
