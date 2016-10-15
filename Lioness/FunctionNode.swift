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
	public let body: [ASTNode]
	
	public init(prototype: PrototypeNode, body: [ASTNode]) {
		self.prototype = prototype
		self.body = body
	}
	
	public override func compile(_ ctx: BytecodeCompiler) throws -> [BytecodeInstruction] {
		
		var bytecode = [BytecodeInstruction]()
	
		for a in body {
			let instructions = try a.compile(ctx)
			bytecode.append(contentsOf: instructions)
		}
	
		return bytecode
		
	}
	
	public override var description: String {
		
		var str = "FunctionNode(prototype: \(prototype), body: ["
		
		for e in body {
			str += "\n    \(e.description)"
		}
		
		return str + "\n])"
	}
	
}

//public func ==(lhs: FunctionNode, rhs: FunctionNode) -> Bool {
//	return lhs.prototype == rhs.prototype && lhs.body == rhs.body
//}
