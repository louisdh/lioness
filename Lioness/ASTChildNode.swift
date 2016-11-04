//
//  ASTChildNode.swift
//  Lioness
//
//  Created by Louis D'hauwe on 04/11/2016.
//  Copyright © 2016 Silver Fox. All rights reserved.
//

import Foundation

public struct ASTChildNode {
	
	public let connectionToParent: String?
	public let isConnectionConditional: Bool
	
	public let node: ASTNode
	
	init(node: ASTNode) {
		
		self.node = node
		self.connectionToParent = nil
		self.isConnectionConditional = false
		
	}
	
	init(connectionToParent: String, node: ASTNode) {
		
		self.connectionToParent = connectionToParent
		self.node = node
		self.isConnectionConditional = false
		
	}
	
	init(connectionToParent: String?, isConnectionConditional: Bool, node: ASTNode) {
		
		self.connectionToParent = connectionToParent
		self.isConnectionConditional = isConnectionConditional
		self.node = node
		
	}
	
}
