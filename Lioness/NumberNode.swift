//
//  NumberNode.swift
//  Lioness
//
//  Created by Louis D'hauwe on 09/10/2016.
//  Copyright © 2016 Silver Fox. All rights reserved.
//

import Foundation

public class NumberNode: ASTNode {
	
	public let value: Double
	
	public init(value: Double) {
		self.value = value
	}
	
	public override func compile(with ctx: BytecodeCompiler) throws -> BytecodeBody {
		
		let i = self.value
		let label = ctx.nextIndexLabel()
		return [BytecodeInstruction(label: label, type: .pushConst, arguments: ["\(i)"])]
		
	}
	
	public override var description: String {
		return "NumberNode(\(value))"
	}
	
	public override var nodeDescription: String? {
		return "\(value)"
	}
	
	public override var childNodes: [ASTChildNode] {
		return []
	}
	
}
