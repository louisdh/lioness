//
//  ValueType.swift
//  Lioness
//
//  Created by Louis D'hauwe on 19/01/2017.
//  Copyright © 2017 Silver Fox. All rights reserved.
//

import Foundation

public typealias NumberType = Double

public enum ValueType: Equatable {
	
	case number(NumberType)
	case `struct`([Int : ValueType])
	
}

public extension ValueType {
	
	func description(with ctx: BytecodeCompiler) -> String {
		
		var descr = ""
		
		switch self {
		case let .number(val):
			
			descr += "\(val)"
			
		case let .struct(val):
			
			descr += "{ "
			
			for (k, v) in val {
				
				if let memberName = ctx.getStructMemberName(for: k) {
					descr += "\(memberName) = "
				} else {
					descr += "\(k) = "
				}
				
				descr += "\(v.description(with: ctx)); "
				
			}
			
			descr += " }"
			
		}
		
		return descr
	}
	
}

public func ==(lhs: ValueType, rhs: ValueType) -> Bool {
	
	if case let ValueType.number(l) = lhs, case let ValueType.number(r) = rhs {
		return l == r
	}
	
	if case let ValueType.struct(l) = lhs, case let ValueType.struct(r) = rhs {
		return l == r
	}
	
	return false
}
