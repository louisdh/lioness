//
//  ScopeNode.swift
//  Lioness
//
//  Created by Louis D'hauwe on 15/11/2016.
//  Copyright © 2016 Silver Fox. All rights reserved.
//

import Foundation

internal class ScopeNode {
	
	weak var parentNode: ScopeNode?
	var childNodes: [ScopeNode]
	
	var registerMap: [String : String]
	
	init(parentNode: ScopeNode? = nil, childNodes: [ScopeNode]) {
		self.parentNode = parentNode
		self.childNodes = childNodes
		registerMap = [String : String]()
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
	
}
