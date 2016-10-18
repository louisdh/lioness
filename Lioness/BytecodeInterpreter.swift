//
//  BytecodeInterpreter.swift
//  Lioness
//
//  Created by Louis D'hauwe on 09/10/2016.
//  Copyright © 2016 Silver Fox. All rights reserved.
//

import Foundation

public enum InterpreterError: Error {
	case unexpectedArgument
}

public class BytecodeInterpreter {
	
	fileprivate let bytecode: [BytecodeInstruction]
	
	typealias StackElement = Double
	
	fileprivate(set) var stack = [StackElement]()
	fileprivate(set) var registers = [String : StackElement]()
	
	public init(bytecode: [BytecodeInstruction]) {
		self.bytecode = bytecode
	}
	
	public init?(bytecodeStrings: [String]) {
		
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
	
	public func interpret() throws {
		
		stack = [StackElement]()
		registers = [String : StackElement]()
		
		// Program counter
		var pc = 0
		
		while pc < bytecode.count {
			
			let instruction = bytecode[pc]
			
			pc = try executeInstruction(instruction, pc: pc)
			
		}
		
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
			
			case .and:
				newPc = executeAnd(pc: pc)
			
			case .or:
				newPc = executeOr(pc: pc)
			
			case .not:
				newPc = executeNot(pc: pc)
			
			case .eq:
				newPc = executeEqual(pc: pc)
				
			case .neq:
				newPc = executeNotEqual(pc: pc)
			
			case .cmple:
				newPc = executeCmpLe(pc: pc)
				
			case .cmplt:
				newPc = executeCmpLt(pc: pc)
			
			case .goto:
				newPc = try executeGoto(instruction)
			
			case .registerStore:
				newPc = try executeStore(instruction, pc: pc)
			
			case .registerClear:
				newPc = try executeRegisterClear(instruction, pc: pc)
			
			case .registerLoad:
				newPc = try executeRegisterLoad(instruction, pc: pc)
		
			case .ifTrue:
				newPc = try executeIfTrue(instruction, pc: pc)
			
			case .ifFalse:
				newPc = try executeIfFalse(instruction, pc: pc)
			
		}
		
		return newPc
	}

	fileprivate func executePushConst(_ instruction: BytecodeInstruction, pc: Int) throws -> Int {
		guard let arg = instruction.arguments.first, let f = StackElement(arg) else {
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

		let rhs = pop()
		let lhs = pop()
		
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
	
	fileprivate func executeAnd(pc: Int) -> Int {
		
		let rhs = pop() == 1.0
		let lhs = pop() == 1.0
		
		let and: StackElement = (rhs && lhs) == true ? 1.0 : 0.0
		
		push(and)
		
		return pc + 1
	}
	
	fileprivate func executeOr(pc: Int) -> Int {
		
		let rhs = pop() == 1.0
		let lhs = pop() == 1.0
		
		let and: StackElement = (rhs || lhs) == true ? 1.0 : 0.0
		
		push(and)
		
		return pc + 1
	}
	
	fileprivate func executeNot(pc: Int) -> Int {
		
		let b = pop() == 1.0
		
		let not: StackElement = (!b) == true ? 1.0 : 0.0
		
		push(not)
		
		return pc + 1
	}
	
	fileprivate func executeEqual(pc: Int) -> Int {
		
		let rhs = pop()
		let lhs = pop()
		
		let eq: StackElement = (lhs == rhs) ? 1.0 : 0.0
		
		push(eq)
		
		return pc + 1
	}
	
	fileprivate func executeNotEqual(pc: Int) -> Int {
		
		let rhs = pop()
		let lhs = pop()
		
		let neq: StackElement = (lhs != rhs) ? 1.0 : 0.0
		
		push(neq)
		
		return pc + 1
	}
	
	fileprivate func executeCmpLe(pc: Int) -> Int {

		let rhs = pop()
		let lhs = pop()
		
		let cmp: StackElement = (lhs <= rhs) ? 1.0 : 0.0
		
		push(cmp)
		
		return pc + 1
	}
	
	fileprivate func executeCmpLt(pc: Int) -> Int {

		let rhs = pop()
		let lhs = pop()
		
		let cmp: StackElement = (lhs < rhs) ? 1.0 : 0.0
		
		push(cmp)
		
		return pc + 1
	}
	
	fileprivate func executeIfTrue(_ instruction: BytecodeInstruction, pc: Int) throws -> Int {
		
		guard let label = instruction.arguments.first else {
			throw InterpreterError.unexpectedArgument
		}
		
		if pop() == 1.0 {
			
			if let newPc = progamCounter(for: label) {
				return newPc
			} else {
				return bytecode.count
			}
			
		}
		
		return pc + 1
		
	}
	
	fileprivate func executeIfFalse(_ instruction: BytecodeInstruction, pc: Int) throws -> Int {
		
		guard let label = instruction.arguments.first else {
			throw InterpreterError.unexpectedArgument
		}
		
		if pop() == 0.0 {
			
			if let newPc = progamCounter(for: label) {
				return newPc
			} else {
				return bytecode.count
			}
		
		}
		
		return pc + 1
		
	}
	
	fileprivate func executeGoto(_ instruction: BytecodeInstruction) throws -> Int {
		
		guard let label = instruction.arguments.first else {
			throw InterpreterError.unexpectedArgument
		}

		if let newPc = progamCounter(for: label) {
			return newPc
		} else {
			return bytecode.count
		}
		
	}
	
	fileprivate func executeStore(_ instruction: BytecodeInstruction, pc: Int) throws -> Int {
		
		guard let reg = instruction.arguments[safe: 0] else {
			throw InterpreterError.unexpectedArgument
		}
		
		registers[reg] = pop()
		
		return pc + 1
	}
	
	fileprivate func executeRegisterClear(_ instruction: BytecodeInstruction, pc: Int) throws -> Int {

		guard let reg = instruction.arguments[safe: 0] else {
			throw InterpreterError.unexpectedArgument
		}
		
		registers.removeValue(forKey: reg)
		
		return pc + 1
	}
	
	fileprivate func executeRegisterLoad(_ instruction: BytecodeInstruction, pc: Int) throws -> Int {
		
		guard let reg = instruction.arguments[safe: 0] else {
			throw InterpreterError.unexpectedArgument
		}
		
		guard let regValue = registers[reg] else {
			throw InterpreterError.unexpectedArgument
		}
		
		push(regValue)
		
		return pc + 1
	}
	
	fileprivate func progamCounter(for label: String) -> Int? {
		
		return bytecode.index(where: { (b) -> Bool in
			b.label == label
		})
		
	}
	
	fileprivate func pop() -> StackElement {
		let last = stack.removeLast()
		return last
	}
	
	fileprivate func push(_ item: StackElement) {
		stack.append(item)
	}

}
