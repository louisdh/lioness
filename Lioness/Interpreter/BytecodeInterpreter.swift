//
//  BytecodeInterpreter.swift
//  Lioness
//
//  Created by Louis D'hauwe on 09/10/2016.
//  Copyright © 2016 - 2017 Silver Fox. All rights reserved.
//

import Foundation

/// Bytecode Interpreter
public class BytecodeInterpreter {
	
	private let stackLimit = 65_536
	
	private let bytecode: BytecodeBody
	
	/// Stack
	private(set) public var stack: Stack<ValueType>
	
	/// Virtual map with id as key and program counter as value
	private var virtualMap = [Int : Int]()

	private var virtualEndMap = [Int : Int]()

	private var virtualInvokeStack: Stack<Int>
	
	private var virtualDepth = 0

	/// Registers
	private(set) public var registers = [Int : ValueType]()
	
	private(set) var pcTrace = [Int]()

	// MARK: - Init
	
	/// Initalize a BytecodeInterpreter with an array of BytecodeInstruction
	///
	/// - Parameter bytecode: Array of BytecodeInstruction
	public init(bytecode: BytecodeBody) throws {
		self.bytecode = bytecode
		
		stack = Stack<ValueType>(withLimit: stackLimit)
		registers = [Int : ValueType]()
		virtualInvokeStack = Stack<Int>(withLimit: stackLimit)
		
		try createFunctionMap()
	}
	
	/// Initalize a BytecodeInterpreter with an array of String
	///
	/// The strings will be parsed into Bytecode Instructions
	///
	/// - Parameter bytecodeStrings: bytecode instructions as strings
	public init?(bytecodeStrings: [String]) {
		
		stack = Stack<ValueType>(withLimit: stackLimit)
		registers = [Int : ValueType]()
		virtualInvokeStack = Stack<Int>(withLimit: stackLimit)

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
	
	private func createFunctionMap() throws {
		
		var pc = 0
		
		var funcStack = [Int]()
		
		for line in bytecode {
			
			if let virtualLine = line as? BytecodeVirtualHeader {
				// + 1 for first line in virtual
				// header should never be jumped to
				virtualMap[virtualLine.id] = pc + 1

				funcStack.append(virtualLine.id)
			}

			if let funcLine = line as? BytecodePrivateFunctionHeader {
				// + 1 for first line in function
				// header should never be jumped to
				virtualMap[funcLine.id] = pc + 1
				
				funcStack.append(funcLine.id)
			}
			
			if line is BytecodeEnd || line is BytecodePrivateEnd {
				
				guard let currentFunc = funcStack.popLast() else {
					throw error(.unexpectedArgument)
				}
				
				virtualEndMap[currentFunc] = pc
				
			}
			
			pc += 1
		}
		
	}
	
	private var pcStart: Int {
		return 0
	}
	
	/// Interpret the bytecode passed in the initializer
	///
	/// - Throws: InterpreterError
	public func interpret() throws {
		
		// Program counter
		var pc = pcStart
		
		while pc < bytecode.count {
			
			pcTrace.append(pc)
			pc = try executeLine(bytecode[pc], pc: pc)
			
		}
		
	}
	
	private func executeLine(_ line: BytecodeLine, pc: Int) throws -> Int {
		
		if let instruction = line as? BytecodeInstruction {
			
			return try executeInstruction(instruction, pc: pc)
			
		} else if line is BytecodeEnd {
			
			// In theory should never be called?
			return try virtualInvokeStack.pop()
			
		} else if let virtualHeader = line as? BytecodeVirtualHeader {
			
			guard let virtualEndPc = virtualEndMap[virtualHeader.id] else {
				throw error(.unexpectedArgument)
			}
			
			return virtualEndPc + 1
			
		} else if line is BytecodePrivateEnd {
			
			return try virtualInvokeStack.pop()
			
		} else if let functionHeader = line as? BytecodePrivateFunctionHeader {
			
			guard let funcEndPc = virtualEndMap[functionHeader.id] else {
				throw error(.unexpectedArgument)
			}
			
			return funcEndPc + 1
			
		} else {
			
			throw error(.unexpectedArgument)
			
		}
		
	}
	
	private func executeInstruction(_ instruction: BytecodeInstruction, pc: Int) throws -> Int {
		
		let newPc: Int
		
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
			
			case .structInit:
				newPc = try executeStructInit(instruction, pc: pc)

			case .structSet:
				newPc = try executeStructSet(instruction, pc: pc)

			case .structUpdate:
				newPc = try executeStructUpdate(instruction, pc: pc)
			
			case .structGet:
				newPc = try executeStructGet(instruction, pc: pc)

		}
		
		return newPc
	}

	// MARK: - Execution

	private func executePushConst(_ instruction: BytecodeInstruction, pc: Int) throws -> Int {

		guard let arg = instruction.arguments.first, case let .value(f) = arg else {
			throw error(.unexpectedArgument)
		}
		
		try stack.push(.number(f))
		
		return pc + 1
	}
	
	private func executeAdd(pc: Int) throws -> Int {
		
		let lhs = try popNumber()
		let rhs = try popNumber()
		
		try stack.push(.number(lhs + rhs))
		
		return pc + 1
	}
	
	private func executeSub(pc: Int) throws -> Int {

		let rhs = try popNumber()
		let lhs = try popNumber()
		
		try stack.push(.number(lhs - rhs))
		
		return pc + 1
	}
	
	private func executeMul(pc: Int) throws -> Int {
		
		let lhs = try popNumber()
		let rhs = try popNumber()
		
		try stack.push(.number(lhs * rhs))
		
		return pc + 1
	}
	
	private func executeDiv(pc: Int) throws -> Int {
		
		let rhs = try popNumber()
		let lhs = try popNumber()

		try stack.push(.number(lhs / rhs))
		
		return pc + 1
	}
	
	private func executePow(pc: Int) throws -> Int {
		
		let rhs = try popNumber()
		let lhs = try popNumber()
		
		try stack.push(.number(pow(lhs, rhs)))
		
		return pc + 1
	}
	
	private func executeAnd(pc: Int) throws -> Int {
		
		let rhs = try popNumber() == 1.0
		let lhs = try popNumber() == 1.0
		
		let and: NumberType = (rhs && lhs) == true ? 1.0 : 0.0
		
		try stack.push(.number(and))
		
		return pc + 1
	}
	
	private func executeOr(pc: Int) throws -> Int {
		
		let rhs = try popNumber() == 1.0
		let lhs = try popNumber() == 1.0
		
		let and: NumberType = (rhs || lhs) == true ? 1.0 : 0.0
		
		try stack.push(.number(and))
		
		return pc + 1
	}
	
	private func executeNot(pc: Int) throws -> Int {
		
		let b = try popNumber() == 1.0
		
		let not: NumberType = (!b) == true ? 1.0 : 0.0
		
		try stack.push(.number(not))
		
		return pc + 1
	}
	
	private func executeEqual(pc: Int) throws -> Int {
		
		let rhs = try stack.pop()
		let lhs = try stack.pop()
		
		let eq: NumberType = (lhs == rhs) ? 1.0 : 0.0
		
		try stack.push(.number(eq))
		
		return pc + 1
	}
	
	private func executeNotEqual(pc: Int) throws -> Int {
		
		let rhs = try stack.pop()
		let lhs = try stack.pop()
		
		let neq: NumberType = (lhs != rhs) ? 1.0 : 0.0
		
		try stack.push(.number(neq))
		
		return pc + 1
	}
	
	private func executeCmpLe(pc: Int) throws -> Int {

		let rhs = try popNumber()
		let lhs = try popNumber()
		
		let cmp: NumberType = (lhs <= rhs) ? 1.0 : 0.0
		
		try stack.push(.number(cmp))
		
		return pc + 1
	}
	
	private func executeCmpLt(pc: Int) throws -> Int {

		let rhs = try popNumber()
		let lhs = try popNumber()
		
		let cmp: NumberType = (lhs < rhs) ? 1.0 : 0.0
		
		try stack.push(.number(cmp))
		
		return pc + 1
	}
	
	private func executeIfTrue(_ instruction: BytecodeInstruction, pc: Int) throws -> Int {
		
		guard let label = instruction.arguments.first else {
			throw error(.unexpectedArgument)
		}
		
		guard case let .index(i) = label else {
			throw error(.unexpectedArgument)
		}
		
		if try popNumber() == 1.0 {
			
			if let newPc = progamCounter(for: i) {
				return newPc
			} else {
				return bytecode.count
			}
			
		}
		
		return pc + 1
		
	}
	
	private func executeIfFalse(_ instruction: BytecodeInstruction, pc: Int) throws -> Int {
		
		guard let label = instruction.arguments.first else {
			throw error(.unexpectedArgument)
		}
		
		guard case let .index(i) = label else {
			throw error(.unexpectedArgument)
		}
		
		if try popNumber() == 0.0 {
			
			if let newPc = progamCounter(for: i) {
				return newPc
			} else {
				return bytecode.count
			}
		
		}
		
		return pc + 1
		
	}
	
	private func executeGoto(_ instruction: BytecodeInstruction) throws -> Int {
		
		guard let label = instruction.arguments.first else {
			throw error(.unexpectedArgument)
		}

		guard case let .index(i) = label else {
			throw error(.unexpectedArgument)
		}
		
		if let newPc = progamCounter(for: i) {
			return newPc
		} else {
			return bytecode.count
		}
		
	}
	
	private func executeStore(_ instruction: BytecodeInstruction, pc: Int) throws -> Int {
		
		guard let reg = instruction.arguments.first else {
			throw error(.unexpectedArgument)
		}
		
		guard case let .index(i) = reg else {
			throw error(.unexpectedArgument)
		}
		
		setRegValue(try stack.pop(), for: i)
		
		return pc + 1
	}
	
	private func executeRegisterUpdate(_ instruction: BytecodeInstruction, pc: Int) throws -> Int {
		
		guard let reg = instruction.arguments.first else {
			throw error(.unexpectedArgument)
		}
		
		guard case let .index(i) = reg else {
			throw error(.unexpectedArgument)
		}
		
		try updateRegValue(try stack.pop(), for: i)
		
		return pc + 1
	}
	
	private func executeRegisterClear(_ instruction: BytecodeInstruction, pc: Int) throws -> Int {

		guard let reg = instruction.arguments.first else {
			throw error(.unexpectedArgument)
		}
		
		guard case let .index(i) = reg else {
			throw error(.unexpectedArgument)
		}
		
		try removeRegValue(in: i)
		
		return pc + 1
	}
	
	private func executeRegisterLoad(_ instruction: BytecodeInstruction, pc: Int) throws -> Int {
		
		guard let reg = instruction.arguments.first else {
			throw error(.unexpectedArgument)
		}
		
		guard case let .index(i) = reg else {
			throw error(.unexpectedArgument)
		}
		
		let regValue = try getRegValue(for: i)
		
		try stack.push(regValue)
		
		return pc + 1
	}
	
	private func executeInvokeFunction(_ instruction: BytecodeInstruction, pc: Int) throws -> Int {
		
		guard let id = instruction.arguments.first else {
			throw error(.unexpectedArgument)
		}
		
		guard case let .index(i) = id else {
			throw error(.unexpectedArgument)
		}
		
		guard let idPc = virtualMap[i] else {
			throw error(.unexpectedArgument)
		}
		
		// return to next pc after virtual returns
		try virtualInvokeStack.push(pc + 1)
		
		if bytecode[idPc - 1] is BytecodeVirtualHeader {
			virtualDepth += 1
		}

		return idPc
	}
	
	private func executeExitFunction(_ instruction: BytecodeInstruction, pc: Int) throws -> Int {
		
		guard let exitFunctionLabel = try? virtualInvokeStack.pop() else {
			throw error(.unexpectedArgument)
		}
		
		virtualDepth -= 1
		
		return exitFunctionLabel
	}
	
	private func executePop(_ instruction: BytecodeInstruction, pc: Int) throws -> Int {
		
		_ = try stack.pop()
		
		return pc + 1
	}
	
	private func executeSkipPast(_ instruction: BytecodeInstruction, pc: Int) throws -> Int {
		
		guard let label = instruction.arguments.first else {
			throw error(.unexpectedArgument)
		}
		
		guard case let .index(i) = label else {
			throw error(.unexpectedArgument)
		}
		
		if let newPc = progamCounter(for: i) {
			// FIXME: need to check if newPc >= bytecode.count?
			return newPc + 1
		} else {
			return bytecode.count
		}
		
	}
	
	private func executeStructInit(_ instruction: BytecodeInstruction, pc: Int) throws -> Int {

		let newStruct = ValueType.struct([:])
		
		try stack.push(newStruct)
		
		return pc + 1
	}

	private func executeStructSet(_ instruction: BytecodeInstruction, pc: Int) throws -> Int {
		
		guard let arg = instruction.arguments.first, case let .index(key) = arg else {
			throw error(.unexpectedArgument)
		}
		
		guard case let ValueType.struct(v) = try stack.pop() else {
			throw error(.unexpectedArgument)
		}
		
		var newStruct = v
		
		newStruct[key] = try stack.pop()

		try stack.push(.struct(newStruct))
		
		return pc + 1
	}

	private func executeStructUpdate(_ instruction: BytecodeInstruction, pc: Int) throws -> Int {

		let memberIds: [Int] = instruction.arguments.flatMap {
			if case let .index(i) = $0 {
				return i
			}
			return nil
		}
		
		guard case let ValueType.struct(v) = try stack.pop() else {
			throw error(.unexpectedArgument)
		}
		
		let updateValue = try stack.pop()
		
		let newStruct = try updatedDict(for: v, keyPath: memberIds, newValue: updateValue)
		
		try stack.push(.struct(newStruct))
		
		return pc + 1
	}
	
	private func executeStructGet(_ instruction: BytecodeInstruction, pc: Int) throws -> Int {
		
		guard let arg = instruction.arguments.first, case let .index(key) = arg else {
			throw error(.unexpectedArgument)
		}
		
		guard case let ValueType.struct(v) = try stack.pop() else {
			throw error(.unexpectedArgument)
		}
		
		guard let memberValue = v[key] else {
			throw error(.unexpectedArgument)
		}
		
		try stack.push(memberValue)
		
		return pc + 1
	}
	
	// MARK: - Structs
	
	/// Get updated dictionary for given dictionary, updating with newValue at keyPath.
	/// Recursively traverses dictionary tree to update a value, then reconstructs the dictionary.
	private func updatedDict(for dict: [Int : ValueType], keyPath: [Int], newValue: ValueType, isReconstructing: Bool = false, trace: [[Int : ValueType]] = [], keyPathPassed: [Int] = []) throws -> [Int : ValueType] {
		
		var trace = trace
		var keyPathPassed = keyPathPassed
		
		if isReconstructing {
			
			if trace.isEmpty {
				return dict
			}
			
			guard let idPassed = keyPathPassed.popLast() else {
				throw error(.unexpectedArgument)
			}
			
			guard let lastTrace = trace.popLast() else {
				throw error(.unexpectedArgument)
			}
			
			var newDict = lastTrace
			newDict[idPassed] = .struct(dict)
			
			return try updatedDict(for: newDict, keyPath: keyPath, newValue: newValue, isReconstructing: true, trace: trace, keyPathPassed: keyPathPassed)
		}
		
		var dict = dict

		guard !keyPath.isEmpty else {
			throw error(.unexpectedArgument)
		}
		
		guard let id = keyPath.last else {
			throw error(.unexpectedArgument)
		}
		
		
		if keyPath.count == 1 {
			
			dict[id] = newValue
			
			return try updatedDict(for: dict, keyPath: keyPath, newValue: newValue, isReconstructing: true, trace: trace, keyPathPassed: keyPathPassed)

		} else {
			
			trace.append(dict)
			keyPathPassed.append(id)

			var keyPath = keyPath

			guard let v = dict[id] else {
				throw error(.unexpectedArgument)
			}
			
			guard case let ValueType.struct(dictToUpdate) = v else {
				throw error(.unexpectedArgument)
			}
			
			keyPath.removeLast()
			
			return try updatedDict(for: dictToUpdate, keyPath: keyPath, newValue: newValue, trace: trace, keyPathPassed: keyPathPassed)
		}
		
	}
	
	// MARK: - Registers
	
	private func removeRegValue(in reg: Int) throws {
		
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
	
	public func getRegValue(for reg: Int) throws -> ValueType {
		
		guard let key = privateReg(for: reg) else {
			throw error(.invalidRegister)
		}

		guard let regValue = registers[key] else {
			throw error(.invalidRegister)
		}
		
		return regValue
	}
	
	private func setRegValue(_ value: ValueType, for reg: Int) {
		
		let privateKey = virtualDepth * regPrivateKeyPrefixSize + reg
		
		// FIXME: make faster?
		if regMap[reg] != nil {
			regMap[reg]?.append(virtualDepth)
		} else {
			regMap[reg] = [virtualDepth]
		}
		
		registers[privateKey] = value
		
	}
	
	private func updateRegValue(_ value: ValueType, for reg: Int) throws {

		guard let privateKey = privateReg(for: reg) else {
			throw error(.invalidRegister)
		}
		
		registers[privateKey] = value
		
	}
	
	/// Maps compiled regs to runtime reg names.
	/// This allows for correct recursion, since multiple variables
	/// with the same name might point to different registers.
	private var regMap = [Int : [Int]]()
	
	// Also the max number of private keys for each reg
	private var regPrivateKeyPrefixSize = 10_000
	
	private func privateReg(for reg: Int) -> Int? {
		
		guard let id = regMap[reg]?.last else {
			return nil
		}
		
		guard reg < regPrivateKeyPrefixSize else {
			return nil
		}
		
		return id * regPrivateKeyPrefixSize + reg
	}
	
	public func regName(for privateReg: Int) -> Int? {
		
		for (k, v) in regMap {
			
			guard k < regPrivateKeyPrefixSize else {
				continue
			}
			
			for reg in v {
				
				let privateKey = reg * regPrivateKeyPrefixSize + k

				if privateKey == privateReg {
					return k
				}
				
			}
			
		}
		
		return nil
	}
	
	// MARK: -
	
	// TODO: max cache size?
	private var labelProgramCountersCache = [Int : Int]()
	
	private func progamCounter(for label: Int) -> Int? {
		
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
			
			if let exitFunctionLabel = try? virtualInvokeStack.pop() {
				
				virtualDepth -= 1
				
				return exitFunctionLabel
			}
			
		}
		
		labelProgramCountersCache[label] = foundLabel
		
		return foundLabel
	}
	
	// MARK: - Stack
	
	private func popNumber() throws -> NumberType {
		
		let last = try stack.pop()
		
		guard case let ValueType.number(number) = last else {
			throw error(.unexpectedArgument)
		}
		
		return number
	}
	
	// MARK: -
	
	private func error(_ type: InterpreterError) -> Error {
		return type
	}
	
}
