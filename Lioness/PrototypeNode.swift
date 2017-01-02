//
//  PrototypeNode.swift
//  Lioness
//
//  Created by Louis D'hauwe on 09/10/2016.
//  Copyright © 2016 - 2017 Silver Fox. All rights reserved.
//

import Foundation

public class PrototypeNode: ASTNode {
	
	public let name: String
	public let argumentNames: [String]
	public let returns: Bool

	public init(name: String, argumentNames: [String] = [], returns: Bool = false) {
		self.name = name
		self.argumentNames = argumentNames
		self.returns = returns
	}
	
	public override var description: String {
		return "PrototypeNode(name: \(name), argumentNames: \(argumentNames), returns: \(returns))"
	}
	
	public override var nodeDescription: String? {
		return "Prototype"
	}
	
	public override var childNodes: [ASTChildNode] {
		return []
	}
	
}
