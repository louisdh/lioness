//
//  StructNode.swift
//  Lioness
//
//  Created by Louis D'hauwe on 09/01/2017.
//  Copyright © 2017 Silver Fox. All rights reserved.
//

import Foundation

public class StructNode: ASTNode {

	public let StructPrototypeNode: StructPrototypeNode
	
	init(StructPrototypeNode: StructPrototypeNode) {
		self.StructPrototypeNode = StructPrototypeNode
	}
	
	public func compile(with ctx: BytecodeCompiler, in parent: ASTNode?) throws -> BytecodeBody {

		// TODO: generate bytecode
//		var bytecode = BytecodeBody()
//
//
//		return bytecode
		
		return []

	}
	
	public var childNodes: [ASTNode] {
		return []
	}
	
	public var description: String {
		return ""
	}
	
	public var nodeDescription: String? {
		return ""
	}
	
	public var descriptionChildNodes: [ASTChildNode] {
		return []
	}
	
}
