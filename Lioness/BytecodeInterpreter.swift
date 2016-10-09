//
//  BytecodeInterpreter.swift
//  Lioness
//
//  Created by Louis D'hauwe on 09/10/2016.
//  Copyright © 2016 Silver Fox. All rights reserved.
//

import Foundation

enum InterpreterError: Error {
	case unexpectedArgument
}

public class BytecodeInterpreter {
	
	fileprivate let bytecode: [BytecodeInstruction]
	
	fileprivate var stack = [Float]()
	
	init(bytecode: [BytecodeInstruction]) {
		self.bytecode = bytecode
	}
	
	init?(bytecodeStrings: [String]) {
		
		var bytecode = [BytecodeInstruction]()
		
		for s in bytecodeStrings {
			if let instruction = try? BytecodeInstruction(instructionString: s) {
				bytecode.append(instruction)
			} else {
				return nil
			}
		}
		
		self.bytecode = bytecode
	}
	
	func interpret() throws {
		
		// Program counter
		var pc = 0
		
		while pc < bytecode.count {
			
			let instruction = bytecode[pc]
			
			pc = try executeInstruction(instruction, pc: pc)
			
		}
		
		print("Stack at end of execution:\n\(stack)")
		
	}
	
	fileprivate func executeInstruction(_ instruction: BytecodeInstruction, pc: Int) throws -> Int {
		
		var newPc: Int
		
		switch instruction.type {
			
			case .pushConst:
				newPc = try executePushConst(instruction, pc: pc)
				
			case .add:
				newPc = executeAdd(pc: pc)
				
			case .sub:
				newPc = executeSub(pc: pc)
				
			case .mul:
				newPc = executeMul(pc: pc)
				
			case .div:
				newPc = executeDiv(pc: pc)
				
			case .pow:
				newPc = executePow(pc: pc)
				
			case .goto:
				newPc = try executeGoto(instruction)
				
		}
		
		return newPc
	}

	fileprivate func executePushConst(_ instruction: BytecodeInstruction, pc: Int) throws -> Int {
		guard let arg = instruction.arguments.first, let f = Float(arg) else {
			throw InterpreterError.unexpectedArgument
		}
		
		push(f)
		
		return pc + 1
	}
	
	fileprivate func executeAdd(pc: Int) -> Int {
		
		let lhs = pop()
		let rhs = pop()
		
		push(lhs + rhs)
		
		return pc + 1
	}
	
	fileprivate func executeSub(pc: Int) -> Int {
		
		let lhs = pop()
		let rhs = pop()
		
		push(lhs - rhs)
		
		return pc + 1
	}
	
	fileprivate func executeMul(pc: Int) -> Int {
		
		let lhs = pop()
		let rhs = pop()
		
		push(lhs * rhs)
		
		return pc + 1
	}
	
	fileprivate func executeDiv(pc: Int) -> Int {
		
		let rhs = pop()
		let lhs = pop()

		push(lhs / rhs)
		
		return pc + 1
	}
	
	fileprivate func executePow(pc: Int) -> Int {
		
		let rhs = pop()
		let lhs = pop()
		
		push(pow(lhs, rhs))
		
		return pc + 1
	}
	
	fileprivate func executeGoto(_ instruction: BytecodeInstruction) throws -> Int {
		
		guard let arg = instruction.arguments.first, let newPc = Int(arg) else {
			throw InterpreterError.unexpectedArgument
		}

		return newPc
	}
	
	fileprivate func pop() -> Float {
		let last = stack.removeLast()
		return last
	}
	
	fileprivate func push(_ item: Float) {
		stack.append(item)
	}

}
