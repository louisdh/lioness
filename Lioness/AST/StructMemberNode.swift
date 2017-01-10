//
//  StructMemberNode.swift
//  Lioness
//
//  Created by Louis D'hauwe on 09/01/2017.
//  Copyright © 2017 Silver Fox. All rights reserved.
//

import Foundation

// TODO: not needed, just use string?
public class StructMemberNode: ASTNode {
	
	public init() {

	}
	
	// TODO: make ASTNode protocol without compile function? (and make one with compile func)
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
