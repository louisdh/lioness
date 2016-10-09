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
	
	init(callee: String, arguments: [ASTNode]) {
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
	
}

//public func ==(lhs: CallNode, rhs: CallNode) -> Bool {
//	return lhs.callee == rhs.callee && lhs.arguments == rhs.arguments
//}
