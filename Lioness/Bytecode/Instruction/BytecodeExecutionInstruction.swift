//
//  BytecodeExecutionInstruction.swift
//  Lioness
//
//  Created by Louis D'hauwe on 08/02/2017.
//  Copyright © 2017 Silver Fox. All rights reserved.
//

import Foundation

// TODO: make struct and test performance
public class BytecodeExecutionInstruction {
	
	let label: Int
	
	let type: BytecodeInstructionType
	
	let arguments: [InstructionArgumentType]
	
	init(label: Int, type: BytecodeInstructionType, arguments: [InstructionArgumentType] = []) {
		self.label = label
		self.type = type
		self.arguments = arguments
	}
	
}
