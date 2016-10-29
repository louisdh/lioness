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
	
	public override var childNodes: [(String?, ASTNode)] {
		var children = [(String?, ASTNode)]()
		
		for a in arguments {
			children.append(("argument", a))
		}
		
		return children
	}
	
}
