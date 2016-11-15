//
//  BytecodeInstruction.swift
//  Lioness
//
//  Created by Louis D'hauwe on 08/10/2016.
//  Copyright © 2016 Silver Fox. All rights reserved.
//

import Foundation

public class BytecodeInstruction: CustomStringConvertible {
	
	let label: String
	
	let type: BytecodeInstructionType
	
	let arguments: [String]
	
	let comment: String?
	
	public init(instructionString: String) throws {
		
		let substrings = instructionString.components(separatedBy: " ")
		
		guard var label = substrings[safe: 0] else {
			throw BytecodeInstruction.error(.invalidDecoding)
		}
		
		guard let colonIndex = label.characters.index(of: ":") else {
			throw BytecodeInstruction.error(.invalidDecoding)
		}
		
		label.remove(at: colonIndex)
		
		self.label = label
		
		guard let command = substrings[safe: 1] else {
			throw BytecodeInstruction.error(.invalidDecoding)
		}
		
		guard let type = BytecodeInstructionType(rawValue: command) else {
			throw BytecodeInstruction.error(.invalidDecoding)
		}
		
		self.type = type
		
		let commentIndex: Int
		
		if let args = substrings[safe: 2]?.components(separatedBy: ",") {
			self.arguments = args
			commentIndex = 3
		} else {
			self.arguments = []
			commentIndex = 2
		}
		
		if var comment = substrings[safe: commentIndex] {
			
			guard let semiColonIndex = label.characters.index(of: ";") else {
				throw BytecodeInstruction.error(.invalidDecoding)
			}
			
			comment.remove(at: semiColonIndex)
			
			self.comment = comment
			
		} else {
			self.comment = nil
		}
		
	}
	
	init(label: String, type: BytecodeInstructionType, arguments: [String], comment: String?) {
		self.label = label
		self.type = type
		self.arguments = arguments
		self.comment = comment
	}
	
	init(label: String, type: BytecodeInstructionType, arguments: [String]) {
		self.label = label
		self.type = type
		self.arguments = arguments
		self.comment = nil
	}
	
	init(label: String, type: BytecodeInstructionType) {
		self.label = label
		self.type = type
		self.arguments = []
		self.comment = nil
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
		
		var descr = "\(label): \(type.command)"
		
		if !args.isEmpty {
			descr += " \(args)"
		}
		
		if let comment = comment {
			descr += " ;\(comment)"
		}
		
		return descr
	}
	
	// MARK -
	
	fileprivate static func error(_ type: BytecodeInstructionError) -> Error {
		return type
	}
	
}
