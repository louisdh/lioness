//
//  Nodes.swift
//  Lioness
//
//  Created by Louis D'hauwe on 04/10/2016.
//  Copyright © 2016 Silver Fox. All rights reserved.
//

import Foundation


enum CompileError: Error {
	case unexpectedCommand
}

/// AST node with a compile function to compile to Scorpion
public class ASTNode: CustomStringConvertible {
	
	public func compile(_ ctx: BytecodeCompiler) throws -> [BytecodeInstruction] {
		
		return []
	}
	
	public var description: String {
		return ""
	}

}

public class NumberNode: ASTNode, Equatable {
	
	public let value: Float
	
	init(value: Float) {
		self.value = value
	}
	
	public override func compile(_ ctx: BytecodeCompiler) -> [BytecodeInstruction] {
		
		let i = self.value
		let label = ctx.nextIndexLabel()
		return [BytecodeInstruction(label: label, type: .pushConst, arguments: ["\(i)"])]
		
	}
	
	public override var description: String {
        return "NumberNode(\(value))"
    }
	
}

public func ==(lhs: NumberNode, rhs: NumberNode) -> Bool {
	return lhs.value == rhs.value
}

public class VariableNode: ASTNode {
	
	public let name: String
	
	init(name: String) {
		self.name = name
	}
	
	public override var description: String {
        return "VariableNode(\(name))"
    }
	
}

public func ==(lhs: VariableNode, rhs: VariableNode) -> Bool {
	return lhs === rhs
}

public class BinaryOpNode: ASTNode {
	
	public let op: String
    public let lhs: ASTNode
    public let rhs: ASTNode
	
	init(op: String, lhs: ASTNode, rhs: ASTNode) {
		self.op = op
		self.lhs = lhs
		self.rhs = rhs
	}
	
	public override func compile(_ ctx: BytecodeCompiler) throws -> [BytecodeInstruction] {
		
		let l = try lhs.compile(ctx)
		let r = try rhs.compile(ctx)
		
		var bytecode = [BytecodeInstruction]()
		
		bytecode.append(contentsOf: l)
		bytecode.append(contentsOf: r)
		
		let label = ctx.nextIndexLabel()
		
		var opTypes: [String : BytecodeInstructionType]
			
		opTypes = ["+" : .add,
		           "-" : .sub,
		           "*" : .mul,
		           "/" : .div,
		           "^" : .pow]
		
		guard let type = opTypes[op] else {
			throw CompileError.unexpectedCommand
		}
		
		let operation = BytecodeInstruction(label: label, type: type)

		bytecode.append(operation)

		return bytecode
		
	}
	
	public override var description: String {
        return "BinaryOpNode(\(op), lhs: \(lhs), rhs: \(rhs))"
    }
	
}

//public func ==(lhs: BinaryOpNode, rhs: BinaryOpNode) -> Bool {
//	return lhs.op == rhs.op && lhs.lhs == rhs.lhs && lhs.rhs == rhs.rhs
//}


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


public class PrototypeNode: ASTNode {
	
    public let name: String
    public let argumentNames: [String]
	
	init(name: String, argumentNames: [String]) {
		self.name = name
		self.argumentNames = argumentNames
	}
	
    public override var description: String {
        return "PrototypeNode(name: \(name), argumentNames: \(argumentNames))"
    }
	
}

public func ==(lhs: PrototypeNode, rhs: PrototypeNode) -> Bool {
	return lhs.name == rhs.name && lhs.argumentNames == rhs.argumentNames
}

public class FunctionNode: ASTNode {
	
    public let prototype: PrototypeNode
    public let body: [ASTNode]
	
	init(prototype: PrototypeNode, body: [ASTNode]) {
		self.prototype = prototype
		self.body = body
	}
	
    public override var description: String {
		
		var str = "FunctionNode(prototype: \(prototype), body: ["
		
		for e in body {
			str += "\n    \(e.description)"
		}
		
        return str + "\n])"
    }
	
}

//public func ==(lhs: FunctionNode, rhs: FunctionNode) -> Bool {
//	return lhs.prototype == rhs.prototype && lhs.body == rhs.body
//}

// Block

// Statement
