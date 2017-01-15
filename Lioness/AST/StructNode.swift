//
//  StructNode.swift
//  Lioness
//
//  Created by Louis D'hauwe on 09/01/2017.
//  Copyright © 2017 Silver Fox. All rights reserved.
//

import Foundation

public class StructNode: ASTNode {

	public let prototype: StructPrototypeNode
	
	init(prototype: StructPrototypeNode) {
		self.prototype = prototype
	}
	
	public func compile(with ctx: BytecodeCompiler, in parent: ASTNode?) throws -> BytecodeBody {

		var bytecode = BytecodeBody()
		
		let structId = ctx.getStructId(for: self)
		
		let header = BytecodeStructHeader(id: structId, name: prototype.name, members: prototype.members)
		bytecode.append(header)

		let initInstr = BytecodeInstruction(label: ctx.nextIndexLabel(), type: .structInit, comment: "init \(prototype.name)")
		bytecode.append(initInstr)
		
		for member in prototype.members.reversed() {
			
			guard let id = ctx.getStructMemberId(for: member) else {
				throw CompileError.unexpectedCommand
			}
			
			let instr = BytecodeInstruction(label: ctx.nextIndexLabel(), type: .structSet, arguments: ["\(id)"], comment: "set \(member)")
			bytecode.append(instr)

		}
		
		bytecode.append(BytecodeEnd())
		
		return bytecode
		
	}
	
	public var childNodes: [ASTNode] {
		return [prototype]
	}
	
	public var description: String {
		return "StructNode(prototype: \(prototype))"
	}
	
	public var nodeDescription: String? {
		return "Struct"
	}
	
	public var descriptionChildNodes: [ASTChildNode] {
		return []
	}
	
}
