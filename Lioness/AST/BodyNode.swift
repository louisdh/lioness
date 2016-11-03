//
//  BodyNode.swift
//  Lioness
//
//  Created by Louis D'hauwe on 26/10/2016.
//  Copyright © 2016 Silver Fox. All rights reserved.
//

import Foundation

public class BodyNode: ASTNode {
	
	public let nodes: [ASTNode]
	
	public init(nodes: [ASTNode]) {
		self.nodes = nodes
	}
	
	public override func compile(with ctx: BytecodeCompiler) throws -> [BytecodeInstruction] {
		
		var bytecode = [BytecodeInstruction]()
		
		for a in nodes {
			let instructions = try a.compile(with: ctx)
			bytecode.append(contentsOf: instructions)
		}
		
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
