//
//  ASTNode.swift
//  Lioness
//
//  Created by Louis D'hauwe on 04/10/2016.
//  Copyright © 2016 Silver Fox. All rights reserved.
//

import Foundation

public enum CompileError: Error {
	case unexpectedCommand
}

/// AST node with a compile function to compile to Scorpion
public class ASTNode: CustomStringConvertible {
	
	/// Compiles to Scorpion bytecode instructions
	public func compile(_ ctx: BytecodeCompiler) throws -> [BytecodeInstruction] {
		
		return []
	}
	
	public var description: String {
		return ""
	}
	
	/// Purely for visualisation
	public var nodeDescription: String? {
		return nil
	}

	/// Purely for visualisation
	public var childNodes: [(String?, ASTNode)] {
		return []
	}

}
