//
//  Stack.swift
//  Lioness
//
//  Created by Louis D'hauwe on 20/01/2017.
//  Copyright © 2017 Silver Fox. All rights reserved.
//

import Foundation

/// LIFO stack
public struct Stack<Element>: CustomStringConvertible {
	
	private var items: [Element]
	private let limit: Int
	
	/// Manual stack size counting for performance
	private(set) var size: Int
	
	init(withLimit limit: Int) {
		self.limit = limit
		items = [Element]()
		items.reserveCapacity(limit)
		size = 0
	}
	
	var isEmpty: Bool {
		return size == 0
	}
	
	mutating func push(_ item: Element) throws {
		
		if size >= limit {
			throw InterpreterError.stackOverflow
		}
		
		items.append(item)
		size += 1
	}
	
	mutating func pop() throws -> Element {
		
		// TODO: is this faster than popLast()?
//		let last = items.remove(at: size - 1)
		
		guard let last = items.popLast() else {
			throw InterpreterError.illegalStackOperation
		}
		
		size -= 1
		
		return last
	}
	
	public var description: String {
		return items.description
	}
	
}
