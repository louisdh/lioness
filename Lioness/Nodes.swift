//
//  Nodes.swift
//  Lioness
//
//  Created by Louis D'hauwe on 04/10/2016.
//  Copyright © 2016 Silver Fox. All rights reserved.
//

import Foundation

public protocol ASTNode: CustomStringConvertible {
	
}

public struct NumberNode: ASTNode {
    public let value: Float
    public var description: String {
        return "NumberNode(\(value))"
    }
}

public struct VariableNode: ASTNode {
    public let name: String
    public var description: String {
        return "VariableNode(\(name))"
    }
}

public struct BinaryOpNode: ASTNode {
    public let op: String
    public let lhs: ASTNode
    public let rhs: ASTNode
    public var description: String {
        return "BinaryOpNode(\(op), lhs: \(lhs), rhs: \(rhs))"
    }
}

public struct CallNode: ASTNode {
    public let callee: String
    public let arguments: [ASTNode]
    public var description: String {
		var str = "CallNode(name: \(callee), argument: "
		
		for a in arguments {
			str += "\n \(a.description)"
		}
		
        return str + ")"
    }
}

public struct PrototypeNode: ASTNode {
    public let name: String
    public let argumentNames: [String]
    public var description: String {
        return "PrototypeNode(name: \(name), argumentNames: \(argumentNames))"
    }
}

public struct FunctionNode: ASTNode {
    public let prototype: PrototypeNode
    public let body: ASTNode
    public var description: String {
        return "FunctionNode(prototype: \(prototype), body: \n\(body))"
    }
}

// Block

// Statement
