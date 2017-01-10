//
//  PrototypeNode.swift
//  Lioness
//
//  Created by Louis D'hauwe on 09/10/2016.
//  Copyright © 2016 - 2017 Silver Fox. All rights reserved.
//

import Foundation

// TODO: rename to FunctionPrototypeNode
public class PrototypeNode: ASTNode {
	
	public let name: String
	public let argumentNames: [String]
	public let returns: Bool

	public init(name: String, argumentNames: [String] = [], returns: Bool = false) {
		self.name = name
		self.argumentNames = argumentNames
		self.returns = returns
	}
	
	// TODO: make ASTNode protocol without compile function? (and make one with compile func)
	public func compile(with ctx: BytecodeCompiler, in parent: ASTNode?) throws -> BytecodeBody {
		return []
	}
	
	public var childNodes: [ASTNode] {
		return []
	}
	
	public var description: String {
		return "PrototypeNode(name: \(name), argumentNames: \(argumentNames), returns: \(returns))"
	}
	
	public var nodeDescription: String? {
		return "Prototype"
	}
	
	public var descriptionChildNodes: [ASTChildNode] {
		return []
	}
	
}
