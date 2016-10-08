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
	
	init(ast: [ASTNode]) {
		self.ast = ast
	}
	
	// MARK: -
	// MARK: Public
	
	func compile() throws -> [String] {

		stack = [Int]()
		
		var bytecode = [String]()

		for a in ast {
			
			bytecode.append(contentsOf: a.compile(self))
			
		}
		
		return bytecode
	}
	
	func indexForNumberNode(numberNode: NumberNode) -> Int {
		
		let numbers = ast.filter { (node) -> Bool in
			return node is NumberNode
		} as! [NumberNode]
		
		return numbers.index(of: numberNode)!
	}

}
