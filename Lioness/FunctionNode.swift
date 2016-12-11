//
//  FunctionNode.swift
//  Lioness
//
//  Created by Louis D'hauwe on 09/10/2016.
//  Copyright © 2016 Silver Fox. All rights reserved.
//

import Foundation

public class FunctionNode: ASTNode {
	
	public let prototype: PrototypeNode
	public let body: BodyNode
	
	public init(prototype: PrototypeNode, body: BodyNode) {
		self.prototype = prototype
		self.body = body
	}
	
	public override func compile(with ctx: BytecodeCompiler) throws -> BytecodeBody {
		
		var bytecode = BytecodeBody()
		
		let functionId = ctx.getFunctionId(for: prototype.name)
		
		let headerInstruction = BytecodeFunctionHeader(name: prototype.name, id: functionId)
	
		bytecode.append(headerInstruction)
		
		let instructions = try body.compile(with: ctx)
		bytecode.append(contentsOf: instructions)
	
		bytecode.append(BytecodeEnd())

		return bytecode
		
	}
	
	public override var description: String {
		
		var str = "FunctionNode(prototype: \(prototype), "
		
		str += "\n    \(body.description)"

		
		return str + ")"
	}
	
	public override var nodeDescription: String? {
		return "Function"
	}
	
	public override var childNodes: [ASTChildNode] {
		var children = [ASTChildNode]()
		
		children.append(contentsOf: body.childNodes)
		
		return children
	}
	
}
