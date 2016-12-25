//
//  BytecodeInstruction.swift
//  Lioness
//
//  Created by Louis D'hauwe on 08/10/2016.
//  Copyright © 2016 Silver Fox. All rights reserved.
//

import Foundation

/// Scorpion Bytecode Instruction
public class BytecodeInstruction: BytecodeLine {
	
	let label: String
	
	let type: BytecodeInstructionType
	
	let arguments: [String]
	
	let comment: String?
	
	/// Use for decoding compiled instructions.
	/// Does not support comments.
	public init(instructionString: String) throws {
		
		let substrings = instructionString.components(separatedBy: " ")
		
		guard let label = substrings[safe: 0] else {
			throw BytecodeInstruction.error(.invalidDecoding)
		}
		
		self.label = label
		
		guard let opCodeString = substrings[safe: 1], let opCode = UInt8(opCodeString) else {
			throw BytecodeInstruction.error(.invalidDecoding)
		}
		
		guard let type = BytecodeInstructionType(rawValue: opCode) else {
			throw BytecodeInstruction.error(.invalidDecoding)
		}
		
		self.type = type
		
		if let args = substrings[safe: 2]?.components(separatedBy: ",") {
			self.arguments = args
		} else {
			self.arguments = []
		}
		
		self.comment = nil

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

	/// Encoding string to use for saving compiled instruction to disk.
	public var encoded: String {
		var args = ""
		
		var i = 0
		for a in arguments {
			args += a
			i += 1
			
			if i != arguments.count {
				args += ","
			}
		}
		
		var descr = "\(label) \(type.opCode)"
		
		if !args.isEmpty {
			descr += " \(args)"
		}
		
		return descr
	}
	
	/// Debug description
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
		
		var descr = "\(label): \(type.description)"
		
		if !args.isEmpty {
			descr += " \(args)"
		}
		
		if let comment = comment {
			descr += "; \(comment)".byAppendingLeading(" ", max(1, 30 - descr.characters.count))
		}
		
		return descr
	}
	
	// MARK: -
	
	fileprivate static func error(_ type: BytecodeInstructionError) -> Error {
		return type
	}
	
}

extension String {
	
	func byAppendingLeading(_ string: String, _ times: Int) -> String {
		return times > 0 ? String(repeating: string, count: times) + self : self
	}
	
}

