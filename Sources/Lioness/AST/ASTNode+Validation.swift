//
//  ASTNode+Validation.swift
//  Lioness
//
//  Created by Louis D'hauwe on 17/11/2016.
//  Copyright © 2016 - 2017 Silver Fox. All rights reserved.
//

import Foundation

extension ASTNode {

	var isValidConditionNode: Bool {

		if self is BinaryOpNode || self is VariableNode || self is InternalVariableNode || self is BooleanNode || self is CallNode || self is StructMemberNode {
			return true
		}

		return false
	}

}

extension ASTNode {

	var isValidBinaryOpNode: Bool {

		if self is BinaryOpNode || self is NumberNode || self is VariableNode || self is InternalVariableNode || self is BooleanNode || self is CallNode || self is StructMemberNode {
			return true
		}

		return false
	}

}
