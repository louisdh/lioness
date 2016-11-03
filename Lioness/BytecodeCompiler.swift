//
//  BytecodeCompiler.swift
//  Lioness
//
//  Created by Louis D'hauwe on 07/10/2016.
//  Copyright © 2016 Silver Fox. All rights reserved.
//

import Foundation

public class BytecodeCompiler {
	
	// MARK: -
	// MARK: Private 
	
	fileprivate let ast: [ASTNode]
	fileprivate var index = 0
	
	fileprivate var scopeStartStack = [String]()
	
	// MARK: -

	public init(ast: [ASTNode]) {
		self.ast = ast
	}
	
	// MARK: -
	// MARK: Public
	
	public func compile() throws -> [BytecodeInstruction] {
		
		var bytecode = [BytecodeInstruction]()

		for node in ast {
			
			let compiled = try node.compile(self)
			bytecode.append(contentsOf: compiled)
			
		}
		
		return bytecode
	}
	
	// MARK: -

	// MARK: - Labels

	func nextIndexLabel() -> String {
		index += 1
		return "\(index)"
	}
	
	func peekNextIndexLabel() -> String {
		return "\(index + 1)"
	}
	
	// MARK: - Scope start stack

	func pushScopeStartStack(_ label: String) {
		scopeStartStack.append(label)
	}

	func popScopeStartStack() -> String? {
		return scopeStartStack.popLast()
	}
	
	func peekScopeStartStack() -> String? {
		return scopeStartStack.last
	}
}
