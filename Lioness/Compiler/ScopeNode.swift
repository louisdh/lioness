//
//  ScopeNode.swift
//  Lioness
//
//  Created by Louis D'hauwe on 15/11/2016.
//  Copyright © 2016 - 2017 Silver Fox. All rights reserved.
//

import Foundation

internal class ScopeNode {
	
	weak var parentNode: ScopeNode?
	var childNodes: [ScopeNode]
	
	var registerMap: [String : String]
	var functionMap: [String : FunctionMapped]
	var internalRegisters: [String]

	// TODO: make Set?
	var registersToClean: [(String, String?)]

	init(parentNode: ScopeNode? = nil, childNodes: [ScopeNode]) {
		self.parentNode = parentNode
		self.childNodes = childNodes
		registerMap = [String : String]()
		functionMap = [String : FunctionMapped]()
		internalRegisters = [String]()
		registersToClean = [(String, String?)]()
	}
	
	func addRegistersToCleanToParent() {
		
		parentNode?.registersToClean.append(contentsOf: registersToClean)
		
	}
	
	/// Get deep register map (including parents' register map)
	func deepRegisterMap() -> [String : String] {
	
		if let parentNode = parentNode {
			
			// Recursive

			var parentMap = parentNode.deepRegisterMap()
			
			registerMap.forEach {
				parentMap[$0.0] = $0.1
			}
			
			return parentMap
		}
		
		return registerMap
	}
	
	/// Get deep function map (including parents' function map)
	func deepFunctionMap() -> [String : FunctionMapped] {
		
		if let parentNode = parentNode {
			
			// Recursive
			
			var parentMap = parentNode.deepFunctionMap()
			
			functionMap.forEach {
				parentMap[$0.0] = $0.1
			}
			
			return parentMap
		}
		
		return functionMap
	}
	
}

struct FunctionMapped {
	
	let id: String
	let exitId: String
	let returns: Bool
	
}

