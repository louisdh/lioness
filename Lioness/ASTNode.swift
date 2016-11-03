//
//  ASTNode.swift
//  Lioness
//
//  Created by Louis D'hauwe on 04/10/2016.
//  Copyright © 2016 Silver Fox. All rights reserved.
//

import Foundation

// TODO: Refactor to separate class?
public enum CompileError: Error {
	case unexpectedCommand
}

// TODO: Refactor to separate class?
public protocol ASTNodeDescriptor {
	
	var nodeDescription: String? {
		get
	}
	
	var childNodes: [ASTChildNode] {
		get
	}
	
}

// TODO: Refactor to separate class?
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

// TODO: Refactor to separate class?

/// AST node with a compile function to compile to Scorpion
public class ASTNode: CustomStringConvertible, ASTNodeDescriptor {
	
	/// Compiles to Scorpion bytecode instructions
	public func compile(with ctx: BytecodeCompiler) throws -> [BytecodeInstruction] {
		return []
	}
	
	public var description: String {
		return ""
	}
	
	public var nodeDescription: String? {
		return nil
	}
	
	public var childNodes: [ASTChildNode] {
		return []
	}

}
