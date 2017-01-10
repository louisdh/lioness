//
//  StructMemberNode.swift
//  Lioness
//
//  Created by Louis D'hauwe on 09/01/2017.
//  Copyright © 2017 Silver Fox. All rights reserved.
//

import Foundation

public class StructMemberNode: ASTNode {

	public let variable: VariableNode
	public let name: String
	
	public init(variable: VariableNode, name: String) {
		self.variable = variable
		self.name = name
	}
	
	public func compile(with ctx: BytecodeCompiler, in parent: ASTNode?) throws -> BytecodeBody {
		return []
	}
	
	public var childNodes: [ASTNode] {
		return []
	}
	
	public var description: String {
		return "StructMemberNode"
	}
	
	public var nodeDescription: String? {
		return "Struct Member"
	}
	
	public var descriptionChildNodes: [ASTChildNode] {
		return []
	}
	
}
