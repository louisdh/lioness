//
//  BytecodeInstruction.swift
//  Lioness
//
//  Created by Louis D'hauwe on 08/10/2016.
//  Copyright © 2016 Silver Fox. All rights reserved.
//

import Foundation

class BytecodeInstruction: CustomStringConvertible {
	
	let label: String
	let instruction: String
	let arguments: [String]
	
	init(label: String, instruction: String, arguments: [String]) {
		self.label = label
		self.instruction = instruction
		self.arguments = arguments
	}

	public var description: String {
		return "\(label): \(instruction) \(arguments)"
	}
	
}
