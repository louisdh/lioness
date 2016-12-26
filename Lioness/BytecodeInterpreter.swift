//
//  BytecodeInterpreter.swift
//  Lioness
//
//  Created by Louis D'hauwe on 09/10/2016.
//  Copyright © 2016 Silver Fox. All rights reserved.
//

import Foundation

/// Bytecode Interpreter
public class BytecodeInterpreter {
	
	fileprivate let stackLimit = 65_536
	
	fileprivate let bytecode: BytecodeBody
	
	typealias StackElement = Double
	
	/// Stack
	fileprivate(set) var stack = [StackElement]()
	
	/// Manual stack size counting for performance
	fileprivate var stackSize = 0
	

	/// Function map with id as key and program counter as value
	fileprivate var functionMap = [String : Int]()

	fileprivate var functionEndMap = [String : Int]()

	fileprivate var functionInvokeStack = [Int]()

	/// Manual stack size counting for performance
	fileprivate var functionInvokeStackSize = 0
	
	/// Registers
	fileprivate(set) var registers = [String : StackElement]()
	
	
	// MARK: - Init
	
	/// Initalize a BytecodeInterpreter with an array of BytecodeInstruction
	///
	/// - Parameter bytecode: Array of BytecodeInstruction
	public init(bytecode: BytecodeBody) throws {
		self.bytecode = bytecode

		try createFunctionMap()
	}
	
	/// Initalize a BytecodeInterpreter with an array of String
	///
	/// The strings will be parsed into Bytecode Instructions
	///
	/// - Parameter bytecodeStrings: bytecode instructions as strings
	public init?(bytecodeStrings: [String]) {
		
		var bytecode = BytecodeBody()
		
		for s in bytecodeStrings {
			if let instruction = try? BytecodeInstruction(instructionString: s) {
				bytecode.append(instruction)
			} else {
				return nil
			}
		}
		
		self.bytecode = bytecode
		
		do {
			try createFunctionMap()
		} catch {
			return nil
		}
		
	}
	
	fileprivate func createFunctionMap() throws {
		
		var pc = 0
		
		var funcStack = [String]()
		
		for line in bytecode {
			
			if let funcLine = line as? BytecodeFunctionHeader {
				// + 1 for first line in function
				// header should never be jumped to
				functionMap[funcLine.id] = pc + 1

				funcStack.append(funcLine.id)
			}

			if line is BytecodeEnd {
				
				guard let currentFunc = funcStack.popLast() else {
					throw error(.unexpectedArgument)
				}
				
				functionEndMap[currentFunc] = pc
				
			}
			
			pc += 1
		}
		
	}
	
	fileprivate var pcStart: Int {
		return 0
	}
	
	/// Interpret the bytecode passed in the initializer
	///
	/// - Throws: InterpreterError
	public func interpret() throws {
		
		stack = [StackElement]()
		registers = [String : StackElement]()
		
		// Program counter
		var pc = pcStart
		
		while pc < bytecode.count {
			
			if let instruction = bytecode[pc] as? BytecodeInstruction {
				
				pc = try executeInstruction(instruction, pc: pc)
				
			} else if bytecode[pc] is BytecodeEnd {
				
				pc = try popFunctionInvoke()
				
			} else if let functionHeader = bytecode[pc] as? BytecodeFunctionHeader {

				guard let funcEndPc = functionEndMap[functionHeader.id] else {
					throw error(.unexpectedArgument)
				}
				
				pc = funcEndPc + 1
				
			} else {
				
				throw error(.unexpectedArgument)
				
			}
			
		}
		
	}
	
	fileprivate func executeInstruction(_ instruction: BytecodeInstruction, pc: Int) throws -> Int {
		
		var newPc: Int
		
		// TODO: Cleaner (more generic) mapping possible?

		switch instruction.type {
			
			case .pushConst:
				newPc = try executePushConst(instruction, pc: pc)
				
			case .add:
				newPc = try executeAdd(pc: pc)
				
			case .sub:
				newPc = try executeSub(pc: pc)
				
			case .mul:
				newPc = try executeMul(pc: pc)
				
			case .div:
				newPc = try executeDiv(pc: pc)
				
			case .pow:
				newPc = try executePow(pc: pc)
			
			case .and:
				newPc = try executeAnd(pc: pc)
			
			case .or:
				newPc = try executeOr(pc: pc)
			
			case .not:
				newPc = try executeNot(pc: pc)
			
			case .eq:
				newPc = try executeEqual(pc: pc)
				
			case .neq:
				newPc = try executeNotEqual(pc: pc)
			
			case .cmple:
				newPc = try executeCmpLe(pc: pc)
				
			case .cmplt:
				newPc = try executeCmpLt(pc: pc)
			
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
			
			case .invokeFunc:
				newPc = try executeInvokeFunction(instruction, pc: pc)
			
		}
		
		return newPc
	}

	// MARK: - Execution

	fileprivate func executePushConst(_ instruction: BytecodeInstruction, pc: Int) throws -> Int {
		guard let arg = instruction.arguments.first, let f = StackElement(arg) else {
			throw error(.unexpectedArgument)
		}
		
		try push(f)
		
		return pc + 1
	}
	
	fileprivate func executeAdd(pc: Int) throws -> Int {
		
		let lhs = try pop()
		let rhs = try pop()
		
		try push(lhs + rhs)
		
		return pc + 1
	}
	
	fileprivate func executeSub(pc: Int) throws -> Int {

		let rhs = try pop()
		let lhs = try pop()
		
		try push(lhs - rhs)
		
		return pc + 1
	}
	
	fileprivate func executeMul(pc: Int) throws -> Int {
		
		let lhs = try pop()
		let rhs = try pop()
		
		try push(lhs * rhs)
		
		return pc + 1
	}
	
	fileprivate func executeDiv(pc: Int) throws -> Int {
		
		let rhs = try pop()
		let lhs = try pop()

		try push(lhs / rhs)
		
		return pc + 1
	}
	
	fileprivate func executePow(pc: Int) throws -> Int {
		
		let rhs = try pop()
		let lhs = try pop()
		
		try push(pow(lhs, rhs))
		
		return pc + 1
	}
	
	fileprivate func executeAnd(pc: Int) throws -> Int {
		
		let rhs = try pop() == 1.0
		let lhs = try pop() == 1.0
		
		let and: StackElement = (rhs && lhs) == true ? 1.0 : 0.0
		
		try push(and)
		
		return pc + 1
	}
	
	fileprivate func executeOr(pc: Int) throws -> Int {
		
		let rhs = try pop() == 1.0
		let lhs = try pop() == 1.0
		
		let and: StackElement = (rhs || lhs) == true ? 1.0 : 0.0
		
		try push(and)
		
		return pc + 1
	}
	
	fileprivate func executeNot(pc: Int) throws -> Int {
		
		let b = try pop() == 1.0
		
		let not: StackElement = (!b) == true ? 1.0 : 0.0
		
		try push(not)
		
		return pc + 1
	}
	
	fileprivate func executeEqual(pc: Int) throws -> Int {
		
		let rhs = try pop()
		let lhs = try pop()
		
		let eq: StackElement = (lhs == rhs) ? 1.0 : 0.0
		
		try push(eq)
		
		return pc + 1
	}
	
	fileprivate func executeNotEqual(pc: Int) throws -> Int {
		
		let rhs = try pop()
		let lhs = try pop()
		
		let neq: StackElement = (lhs != rhs) ? 1.0 : 0.0
		
		try push(neq)
		
		return pc + 1
	}
	
	fileprivate func executeCmpLe(pc: Int) throws -> Int {

		let rhs = try pop()
		let lhs = try pop()
		
		let cmp: StackElement = (lhs <= rhs) ? 1.0 : 0.0
		
		try push(cmp)
		
		return pc + 1
	}
	
	fileprivate func executeCmpLt(pc: Int) throws -> Int {

		let rhs = try pop()
		let lhs = try pop()
		
		let cmp: StackElement = (lhs < rhs) ? 1.0 : 0.0
		
		try push(cmp)
		
		return pc + 1
	}
	
	fileprivate func executeIfTrue(_ instruction: BytecodeInstruction, pc: Int) throws -> Int {
		
		guard let label = instruction.arguments.first else {
			throw error(.unexpectedArgument)
		}
		
		if try pop() == 1.0 {
			
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
			throw error(.unexpectedArgument)
		}
		
		if try pop() == 0.0 {
			
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
			throw error(.unexpectedArgument)
		}

		if let newPc = progamCounter(for: label) {
			return newPc
		} else {
			return bytecode.count
		}
		
	}
	
	fileprivate func executeStore(_ instruction: BytecodeInstruction, pc: Int) throws -> Int {
		
		guard let reg = instruction.arguments.first else {
			throw error(.unexpectedArgument)
		}
		
		registers[reg] = try pop()
		
		return pc + 1
	}
	
	fileprivate func executeRegisterClear(_ instruction: BytecodeInstruction, pc: Int) throws -> Int {

		guard let reg = instruction.arguments.first else {
			throw error(.unexpectedArgument)
		}
		
		registers.removeValue(forKey: reg)
		
		return pc + 1
	}
	
	fileprivate func executeRegisterLoad(_ instruction: BytecodeInstruction, pc: Int) throws -> Int {
		
		guard let reg = instruction.arguments.first else {
			throw error(.unexpectedArgument)
		}
		
		guard let regValue = registers[reg] else {
			throw error(.unexpectedArgument)
		}
		
		try push(regValue)
		
		return pc + 1
	}
	
	fileprivate func executeInvokeFunction(_ instruction: BytecodeInstruction, pc: Int) throws -> Int {
		
		guard let id = instruction.arguments.first else {
			throw error(.unexpectedArgument)
		}
		
		guard let idPc = functionMap[id] else {
			throw error(.unexpectedArgument)
		}
		
		// return to next pc after function returns
		try pushFunctionInvoke(pc + 1)
		
		return idPc
	}
	
	fileprivate func progamCounter(for label: String) -> Int? {
		
		let foundLabel = bytecode.index(where: { (b) -> Bool in
			if let b = b as? BytecodeInstruction {
				return b.label == label
			}
			return false
		})
		
		if foundLabel == nil {
			
			if let exitFunctionLabel = functionInvokeStack.popLast() {
				return exitFunctionLabel
			}
			
		}
		
		return foundLabel
		
	}
	
	// MARK: - Stack

	/// Pop from stack
	fileprivate func pop() throws -> StackElement {
		
		guard let last = stack.popLast() else {
			throw error(.illegalStackOperation)
		}
		
		stackSize -= 1

		return last
	}
	
	/// Push to stack
	fileprivate func push(_ item: StackElement) throws {
		
		if stackSize >= stackLimit {
			throw error(.stackOverflow)
		}
		
		stack.append(item)
		stackSize += 1
	}

	// MARK: - Function invoke stack

	/// Pop from function invoke stack
	fileprivate func popFunctionInvoke() throws -> Int {
		
		guard let last = functionInvokeStack.popLast() else {
			throw error(.illegalStackOperation)
		}
		
		functionInvokeStackSize -= 1
		
		return last
	}
	
	/// Push to function invoke stack
	fileprivate func pushFunctionInvoke(_ item: Int) throws {
		
		if functionInvokeStackSize >= stackLimit {
			throw error(.stackOverflow)
		}
		
		functionInvokeStack.append(item)
		functionInvokeStackSize += 1
	}

	
	// MARK: -
	
	fileprivate func error(_ type: InterpreterError) -> Error {
		return type
	}
	
}
