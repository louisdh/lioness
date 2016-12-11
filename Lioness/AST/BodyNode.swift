//
//  BodyNode.swift
//  Lioness
//
//  Created by Louis D'hauwe on 26/10/2016.
//  Copyright © 2016 Silver Fox. All rights reserved.
//

import Foundation

/// Body that defines a scope
public class BodyNode: ASTNode {
	
	public let nodes: [ASTNode]
	
	public init(nodes: [ASTNode]) {
		self.nodes = nodes
	}
	
	public override func compile(with ctx: BytecodeCompiler) throws -> BytecodeBody {
		
		ctx.enterNewScope()
		
		var bytecode = BytecodeBody()
		
		for a in nodes {
			let instructions = try a.compile(with: ctx)
			bytecode.append(contentsOf: instructions)
		}
		
		let cleanupInstructions = try ctx.leaveCurrentScope()
		bytecode.append(contentsOf: cleanupInstructions)
		
		return bytecode
		
	}
	
	public override var description: String {
		var str = ""
		
		for a in nodes {
			str += "\n    \(a.description)"
		}
		
		return str
	}
	
	public override var nodeDescription: String? {
		return "body"
	}
	
	public override var childNodes: [ASTChildNode] {
		var children = [ASTChildNode]()
		
		for a in nodes {
			children.append(ASTChildNode(node: a))
		}
		
		return children
	}
}
