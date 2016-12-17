//
//  CallNode.swift
//  Lioness
//
//  Created by Louis D'hauwe on 09/10/2016.
//  Copyright © 2016 Silver Fox. All rights reserved.
//

import Foundation

public class CallNode: ASTNode {
	
	public let callee: String
	public let arguments: [ASTNode]
	
	public init(callee: String, arguments: [ASTNode]) {
		self.callee = callee
		self.arguments = arguments
	}
	
	public override func compile(with ctx: BytecodeCompiler) throws -> BytecodeBody {

		var bytecode = BytecodeBody()
		
		let id = ctx.getFunctionId(for: callee)
		
		for arg in arguments {
			
			let argInstructions = try arg.compile(with: ctx)
			bytecode.append(contentsOf: argInstructions)
			
		}
		
		let invokeInstruction = BytecodeInstruction(label: ctx.nextIndexLabel(), type: .invokeFunc, arguments: [id], comment: "\(callee)")

		bytecode.append(invokeInstruction)
		
		return bytecode
	}
	
	public override var description: String {
		var str = "CallNode(name: \(callee), argument: "
		
		for a in arguments {
			str += "\n    \(a.description)"
		}
		
		return str + ")"
	}
	
	public override var nodeDescription: String? {
		return callee
	}
	
	public override var childNodes: [ASTChildNode] {
		var children = [ASTChildNode]()
		
		for a in arguments {
			children.append(ASTChildNode(connectionToParent: "argument", node: a))
		}
		
		return children
	}
	
}
