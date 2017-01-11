//
//  BytecodeInterpreter.swift
//  Lioness
//
//  Created by Louis D'hauwe on 09/10/2016.
//  Copyright © 2016 - 2017 Silver Fox. All rights reserved.
//

import Foundation

public typealias NumberType = Double

public enum ValueType: Equatable {
	
	case number(NumberType)
	case `enum`([ValueType])
	
}

public func ==(lhs: ValueType, rhs: ValueType) -> Bool {
	
	if case let ValueType.number(l) = lhs, case let ValueType.number(r) = rhs {
		return l == r
	}
	
	if case let ValueType.enum(l) = lhs, case let ValueType.enum(r) = rhs {
		return l == r
	}
	
	return false
}

/// Bytecode Interpreter
public class BytecodeInterpreter {
	
	fileprivate let stackLimit = 65_536
	
	fileprivate let bytecode: BytecodeBody
	
	/// Stack
	fileprivate(set) public var stack = [ValueType]()
	
	/// Manual stack size counting for performance
	fileprivate var stackSize = 0
	

	/// Function map with id as key and program counter as value
	fileprivate var functionMap = [String : Int]()

	fileprivate var functionEndMap = [String : Int]()

	fileprivate var functionInvokeStack = [Int]()
	
	fileprivate var functionDepth = 0

	/// Manual stack size counting for performance
	fileprivate var functionInvokeStackSize = 0
	
	/// Registers
	fileprivate(set) public var registers = [String : ValueType]()
	
	fileprivate(set) var pcTrace = [Int]()

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

			if let funcLine = line as? BytecodePrivateFunctionHeader {
				// + 1 for first line in function
				// header should never be jumped to
				functionMap[funcLine.id] = pc + 1
				
				funcStack.append(funcLine.id)
			}
			
			if line is BytecodeEnd || line is BytecodePrivateEnd {
				
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
		
		stack = [ValueType]()
		registers = [String : ValueType]()
		
		// Program counter
		var pc = pcStart
		
		while pc < bytecode.count {
			
			pcTrace.append(pc)
			pc = try executeLine(bytecode[pc], pc: pc)
			
		}
		
	}
	
	fileprivate func executeLine(_ line: BytecodeLine, pc: Int) throws -> Int {
		
		if let instruction = line as? BytecodeInstruction {
			
			return try executeInstruction(instruction, pc: pc)
			
		} else if line is BytecodeEnd {
			
			// In theory should never be called?
			return try popFunctionInvoke()
			
		} else if let functionHeader = line as? BytecodeFunctionHeader {
			
			guard let funcEndPc = functionEndMap[functionHeader.id] else {
				throw error(.unexpectedArgument)
			}
			
			return funcEndPc + 1
			
		} else if line is BytecodePrivateEnd {
			
			return try popFunctionInvoke()
			
		} else if let functionHeader = line as? BytecodePrivateFunctionHeader {
			
			guard let funcEndPc = functionEndMap[functionHeader.id] else {
				throw error(.unexpectedArgument)
			}
			
			return funcEndPc + 1
			
		} else {
			
			throw error(.unexpectedArgument)
			
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
			
			case .registerUpdate:
				newPc = try executeRegisterUpdate(instruction, pc: pc)
			
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
			
			case .exitFunc:
				newPc = try executeExitFunction(instruction, pc: pc)

			case .pop:
				newPc = try executePop(instruction, pc: pc)
			
			case .skipPast:
				newPc = try executeSkipPast(instruction, pc: pc)
			
		}
		
		return newPc
	}

	// MARK: - Execution

	fileprivate func executePushConst(_ instruction: BytecodeInstruction, pc: Int) throws -> Int {
		// TODO: add enum support
		guard let arg = instruction.arguments.first, let f = NumberType(arg) else {
			throw error(.unexpectedArgument)
		}
		
		try push(.number(f))
		
		return pc + 1
	}
	
	fileprivate func executeAdd(pc: Int) throws -> Int {
		
		let lhs = try popNumber()
		let rhs = try popNumber()
		
		try push(.number(lhs + rhs))
		
		return pc + 1
	}
	
	fileprivate func executeSub(pc: Int) throws -> Int {

		let rhs = try popNumber()
		let lhs = try popNumber()
		
		try push(.number(lhs - rhs))
		
		return pc + 1
	}
	
	fileprivate func executeMul(pc: Int) throws -> Int {
		
		let lhs = try popNumber()
		let rhs = try popNumber()
		
		try push(.number(lhs * rhs))
		
		return pc + 1
	}
	
	fileprivate func executeDiv(pc: Int) throws -> Int {
		
		let rhs = try popNumber()
		let lhs = try popNumber()

		try push(.number(lhs / rhs))
		
		return pc + 1
	}
	
	fileprivate func executePow(pc: Int) throws -> Int {
		
		let rhs = try popNumber()
		let lhs = try popNumber()
		
		try push(.number(pow(lhs, rhs)))
		
		return pc + 1
	}
	
	fileprivate func executeAnd(pc: Int) throws -> Int {
		
		let rhs = try popNumber() == 1.0
		let lhs = try popNumber() == 1.0
		
		let and: NumberType = (rhs && lhs) == true ? 1.0 : 0.0
		
		try push(.number(and))
		
		return pc + 1
	}
	
	fileprivate func executeOr(pc: Int) throws -> Int {
		
		let rhs = try popNumber() == 1.0
		let lhs = try popNumber() == 1.0
		
		let and: NumberType = (rhs || lhs) == true ? 1.0 : 0.0
		
		try push(.number(and))
		
		return pc + 1
	}
	
	fileprivate func executeNot(pc: Int) throws -> Int {
		
		let b = try popNumber() == 1.0
		
		let not: NumberType = (!b) == true ? 1.0 : 0.0
		
		try push(.number(not))
		
		return pc + 1
	}
	
	fileprivate func executeEqual(pc: Int) throws -> Int {
		
		let rhs = try popNumber()
		let lhs = try popNumber()
		
		let eq: NumberType = (lhs == rhs) ? 1.0 : 0.0
		
		try push(.number(eq))
		
		return pc + 1
	}
	
	fileprivate func executeNotEqual(pc: Int) throws -> Int {
		
		let rhs = try popNumber()
		let lhs = try popNumber()
		
		let neq: NumberType = (lhs != rhs) ? 1.0 : 0.0
		
		try push(.number(neq))
		
		return pc + 1
	}
	
	fileprivate func executeCmpLe(pc: Int) throws -> Int {

		let rhs = try popNumber()
		let lhs = try popNumber()
		
		let cmp: NumberType = (lhs <= rhs) ? 1.0 : 0.0
		
		try push(.number(cmp))
		
		return pc + 1
	}
	
	fileprivate func executeCmpLt(pc: Int) throws -> Int {

		let rhs = try popNumber()
		let lhs = try popNumber()
		
		let cmp: NumberType = (lhs < rhs) ? 1.0 : 0.0
		
		try push(.number(cmp))
		
		return pc + 1
	}
	
	fileprivate func executeIfTrue(_ instruction: BytecodeInstruction, pc: Int) throws -> Int {
		
		guard let label = instruction.arguments.first else {
			throw error(.unexpectedArgument)
		}
		
		if try popNumber() == 1.0 {
			
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
		
		if try popNumber() == 0.0 {
			
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
		
		setRegValue(try pop(), for: reg)
		
		return pc + 1
	}
	
	fileprivate func executeRegisterUpdate(_ instruction: BytecodeInstruction, pc: Int) throws -> Int {
		
		guard let reg = instruction.arguments.first else {
			throw error(.unexpectedArgument)
		}
		
		try updateRegValue(try pop(), for: reg)
		
		return pc + 1
	}
	
	fileprivate func executeRegisterClear(_ instruction: BytecodeInstruction, pc: Int) throws -> Int {

		guard let reg = instruction.arguments.first else {
			throw error(.unexpectedArgument)
		}
		
		try removeRegValue(in: reg)
		
		return pc + 1
	}
	
	fileprivate func executeRegisterLoad(_ instruction: BytecodeInstruction, pc: Int) throws -> Int {
		
		guard let reg = instruction.arguments.first else {
			throw error(.unexpectedArgument)
		}
		
		let regValue = try getRegValue(for: reg)
		
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
		
		// TODO: if not private function {
		if bytecode[idPc - 1] is BytecodeFunctionHeader {
			functionDepth += 1
		}

		return idPc
	}
	
	fileprivate func executeExitFunction(_ instruction: BytecodeInstruction, pc: Int) throws -> Int {
		
		guard let exitFunctionLabel = functionInvokeStack.popLast() else {
			throw error(.unexpectedArgument)
		}
		
		functionDepth -= 1
		
		return exitFunctionLabel
	}
	
	fileprivate func executePop(_ instruction: BytecodeInstruction, pc: Int) throws -> Int {
		
		_ = try pop()
		
		return pc + 1
	}
	
	fileprivate func executeSkipPast(_ instruction: BytecodeInstruction, pc: Int) throws -> Int {
		
		guard let label = instruction.arguments.first else {
			throw error(.unexpectedArgument)
		}
		
		if let newPc = progamCounter(for: label) {
			// FIXME: need to check if newPc >= bytecode.count?
			return newPc + 1
		} else {
			return bytecode.count
		}
		
	}
	
	
	// MARK: - Registers
	
	fileprivate func removeRegValue(in reg: String) throws {
		
		guard let key = privateReg(for: reg) else {
			return
//			throw error(.unexpectedArgument)
		}
		
		regMap[reg]?.removeLast()

		registers.removeValue(forKey: key)

		// TODO: throw error?
//		guard let _ = registers.removeValue(forKey: key) else {
//			throw error(.unexpectedArgument)
//		}
	}
	
	public func getRegValue(for reg: String) throws -> ValueType {
		
		guard let key = privateReg(for: reg) else {
			throw error(.invalidRegister)
		}

		guard let regValue = registers[key] else {
			throw error(.invalidRegister)
		}
		
		return regValue
	}
	
	fileprivate func setRegValue(_ value: ValueType, for reg: String) {
		
		let privateKey = "\(functionDepth)_\(reg)"
		
		// FIXME: make faster?
		if regMap[reg] != nil {
			regMap[reg]?.append(functionDepth)
		} else {
			regMap[reg] = [functionDepth]
		}
		
		registers[privateKey] = value
		
	}
	
	fileprivate func updateRegValue(_ value: ValueType, for reg: String) throws {

		guard let privateKey = privateReg(for: reg) else {
			throw error(.invalidRegister)
		}
		
		registers[privateKey] = value
		
	}
	
	fileprivate var regMap = [String : [Int]]()
	
	fileprivate func privateReg(for reg: String) -> String? {
		
		guard let id = regMap[reg]?.last else {
			return nil
		}
		
		return "\(id)_\(reg)"
	}
	
	public func regName(for privateReg: String) -> String? {
		
		for (k, v) in regMap {
			
			for reg in v {
				
				let privateKey = "\(reg)_\(k)"

				if privateKey == privateReg {
					return k
				}
				
			}
			
		}
		
		return nil
	}
	
	// MARK: -
	
	// TODO: max cache size?
	fileprivate var labelProgramCountersCache = [String : Int]()
	
	fileprivate func progamCounter(for label: String) -> Int? {
		
		if let pc = labelProgramCountersCache[label] {
			return pc
		}
		
		let foundLabel = bytecode.index(where: { (b) -> Bool in
			if let b = b as? BytecodeInstruction {
				return b.label == label
			}
			return false
		})
		
		if foundLabel == nil {
			
			if let exitFunctionLabel = functionInvokeStack.popLast() {
				
				functionDepth -= 1
				
				return exitFunctionLabel
			}
			
		}
		
		labelProgramCountersCache[label] = foundLabel
		
		return foundLabel
	}
	
	// MARK: - Stack
	
	fileprivate func popNumber() throws -> NumberType {
		
		guard let last = stack.popLast() else {
			throw error(.illegalStackOperation)
		}
		
		guard case let ValueType.number(number) = last else {
			throw error(.unexpectedArgument)
		}
		
		stackSize -= 1
		
		return number
	}

	/// Pop from stack
	fileprivate func pop() throws -> ValueType {
		
		guard let last = stack.popLast() else {
			throw error(.illegalStackOperation)
		}
		
		stackSize -= 1

		return last
	}
	
	/// Push to stack
	fileprivate func push(_ item: ValueType) throws {
		
		if stackSize >= stackLimit {
			throw error(.stackOverflow)
		}
		
		stack.append(item)
		stackSize += 1
	}

	// MARK: - Function invoke stack

	/// Pop from function invoke stack
	fileprivate func popFunctionInvoke() throws -> Int {
		
		// TODO: is this faster than popLast()?
//		let last = functionInvokeStack.remove(at: functionInvokeStackSize - 1)
		
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
