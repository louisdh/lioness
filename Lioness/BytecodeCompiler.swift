//
//  BytecodeCompiler.swift
//  Lioness
//
//  Created by Louis D'hauwe on 07/10/2016.
//  Copyright © 2016 Silver Fox. All rights reserved.
//

import Foundation

public class BytecodeCompiler {
	
	fileprivate let ast: [ASTNode]
	fileprivate var index = 0
	
	fileprivate var stack = [Int]()
	
	public init(ast: [ASTNode]) {
		self.ast = ast
	}
	
	// MARK: -
	// MARK: Public
	
	public func compile() throws -> [BytecodeInstruction] {

		stack = [Int]()
		
		var bytecode = [BytecodeInstruction]()

		for a in ast {
			
			let compiled = try a.compile(self)
			bytecode.append(contentsOf: compiled)
			
		}
		
		return bytecode
	}
	
	func nextIndexLabel() -> String {
		index += 1
		return "\(index)"
	}

}
