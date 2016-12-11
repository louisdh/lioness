//
//  PrototypeNode.swift
//  Lioness
//
//  Created by Louis D'hauwe on 09/10/2016.
//  Copyright © 2016 Silver Fox. All rights reserved.
//

import Foundation

public class PrototypeNode: ASTNode {
	
	public let name: String
	public let argumentNames: [String]
	
	public init(name: String, argumentNames: [String] = []) {
		self.name = name
		self.argumentNames = argumentNames
	}
	
	public override var description: String {
		return "PrototypeNode(name: \(name), argumentNames: \(argumentNames))"
	}
	
	public override var nodeDescription: String? {
		return "Prototype"
	}
	
	public override var childNodes: [ASTChildNode] {
		return []
	}
	
}
