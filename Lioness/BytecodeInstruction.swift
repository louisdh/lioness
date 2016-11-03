//
//  BytecodeInstruction.swift
//  Lioness
//
//  Created by Louis D'hauwe on 08/10/2016.
//  Copyright © 2016 Silver Fox. All rights reserved.
//

import Foundation

// TODO: Refactor to separate class?
public enum BytecodeInstructionError: Error {
	case invalidDecoding
}

public class BytecodeInstruction: CustomStringConvertible {
	
	let label: String
	let type: BytecodeInstructionType
	let arguments: [String]
	
	// TODO: Comment support (';' as marker?)
	
	public init(instructionString: String) throws {
		
		let substrings = instructionString.components(separatedBy: " ")
		
		guard var label = substrings[safe: 0] else {
			throw BytecodeInstructionError.invalidDecoding
		}
		
		guard let colonIndex = label.characters.index(of: ":") else {
			throw BytecodeInstructionError.invalidDecoding
		}
		
		label.remove(at: colonIndex)
		
		self.label = label
		
		guard let command = substrings[safe: 1] else {
			throw BytecodeInstructionError.invalidDecoding
		}
		
		guard let type = BytecodeInstructionType(rawValue: command) else {
			throw BytecodeInstructionError.invalidDecoding
		}
		
		self.type = type
		
		if let args = substrings[safe: 2]?.components(separatedBy: ",") {
			self.arguments = args
		} else {
			self.arguments = []
		}
		
	}
	
	init(label: String, type: BytecodeInstructionType, arguments: [String]) {
		self.label = label
		self.type = type
		self.arguments = arguments
	}
	
	init(label: String, type: BytecodeInstructionType) {
		self.label = label
		self.type = type
		self.arguments = []
	}

	public var description: String {
		var args = ""
		
		var i = 0
		for a in arguments {
			args += a
			i += 1
			
			if i != arguments.count {
				args += ","
			}
		}
		
		return "\(label): \(type.command) \(args)"
	}
	
}

// TODO: Move to separate extension file?
extension Array {
	subscript (safe index: Int) -> Element? {
		return indices ~= index ? self[index] : nil
	}
}
