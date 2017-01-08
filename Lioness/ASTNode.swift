//
//  ASTNode.swift
//  Lioness
//
//  Created by Louis D'hauwe on 04/10/2016.
//  Copyright © 2016 - 2017 Silver Fox. All rights reserved.
//

import Foundation

/// AST node with a compile function to compile to Scorpion
public protocol ASTNode: CustomStringConvertible, ASTNodeDescriptor {
	
	/// Compiles to Scorpion bytecode instructions
	func compile(with ctx: BytecodeCompiler) throws -> BytecodeBody
	
	var description: String { get }
	
	var nodeDescription: String? { get }
	
	var childNodes: [ASTChildNode] { get }

}
