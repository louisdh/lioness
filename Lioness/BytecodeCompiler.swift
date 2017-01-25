//
//  BytecodeCompiler.swift
//  Lioness
//
//  Created by Louis D'hauwe on 07/10/2016.
//  Copyright © 2016 - 2017 Silver Fox. All rights reserved.
//

import Foundation

/// Scorpion Bytecode Compiler
public class BytecodeCompiler {
	
	// MARK: - Private
	
	private var index: UInt
	
	private var loopHeaderStack: [String]
	private var loopContinueStack: [String]

	private var functionExitStack: [String]
	
	private var structMemberIndex: Int

	private var structMemberMap: [String : Int]

	private let scopeTreeRoot: ScopeNode

	private var currentScopeNode: ScopeNode

	// MARK: -

	public init() {
		
		index = 0
		
		loopHeaderStack = [String]()
		loopContinueStack = [String]()
		functionExitStack = [String]()

		scopeTreeRoot = ScopeNode(childNodes: [])
		currentScopeNode = scopeTreeRoot
		
		structMemberIndex = 0
		structMemberMap = [String : Int]()
		
	}
	
	// MARK: - Public
	
	public func compile(_ ast: [ASTNode]) throws -> BytecodeBody {
		
		try compileFunctionPrototypes(for: ast)
		try mapStructMembers(for: ast)
		
		var bytecode = BytecodeBody()

		for node in ast {
			
			let compiled = try node.compile(with: self, in: nil)
			bytecode.append(contentsOf: compiled)
			
		}
		
		let cleanupGlobal = cleanupRegisterInstructions()
		bytecode.append(contentsOf: cleanupGlobal)
		
		return bytecode
	}
	
	// MARK: -
	
	private func mapStructMembers(for ast: [ASTNode]) throws {

		for node in ast {
			
			if let structNode = node as? StructNode {
				
				for memberName in structNode.prototype.members {
				
					if !structMemberMap.keys.contains(memberName) {
						structMemberIndex += 1
						structMemberMap[memberName] = structMemberIndex
					}
					
				}
				
			}
			
		}
		
	}
	
	private func compileFunctionPrototypes(for ast: [ASTNode]) throws {
		
		for node in ast {
			
			if let funcNode = node as? FunctionNode {
				
				let _ = getFunctionId(for: funcNode)
				
				try compileFunctionPrototypes(for: funcNode.childNodes)
				
			} else {
				
				try compileFunctionPrototypes(for: node.childNodes)
				
			}
			
		}
		
	}
	
	// MARK: - Labels

	func nextIndexLabel() -> String {
		index += 1
		return "\(index)"
	}
	
	func peekNextIndexLabel() -> String {
		return "\(index + 1)"
	}
	
	public func currentLabelIndex() -> UInt {
		return index
	}
	
	/// Explicitly set the label index.
	/// Meant for code injection.
	public func setLabelIndex(to newIndex: UInt) {
		index = newIndex
	}
	
	// TODO: make stack operations throw?

	// MARK: - Loop header
	
	func pushLoopHeader(_ label: String) {
		loopHeaderStack.append(label)
	}
	
	@discardableResult
	func popLoopHeader() -> String? {
		return loopHeaderStack.popLast()
	}
	
	func peekLoopHeader() -> String? {
		return loopHeaderStack.last
	}
	
	// MARK: - Loop continue
	
	func pushLoopContinue(_ label: String) {
		loopContinueStack.append(label)
	}
	
	func popLoopContinue() -> String? {
		return loopContinueStack.popLast()
	}
	
	func peekLoopContinue() -> String? {
		return loopContinueStack.last
	}
	
	// MARK: - Return stack
	
	func pushFunctionExit(_ label: String) {
		functionExitStack.append(label)
	}
	
	@discardableResult
	func popFunctionExit() -> String? {
		return functionExitStack.popLast()
	}
	
	func peekFunctionExit() -> String? {
		return functionExitStack.last
	}
	
	// MARK: - Scope tree

	func enterNewScope() {
		
		let newScopeNode = ScopeNode(parentNode: currentScopeNode, childNodes: [])
		currentScopeNode.childNodes.append(newScopeNode)
		currentScopeNode = newScopeNode
		
	}
	
	func addCleanupRegistersToCurrentScope() {

		let regsToClean = registersToClean(for: currentScopeNode)
		currentScopeNode.registersToClean.append(contentsOf: regsToClean)

	}

	func addCleanupRegistersToParentScope() {
		
		currentScopeNode.addRegistersToCleanToParent()
		
	}
	
	func leaveCurrentScope() throws {
		
		guard let parentNode = currentScopeNode.parentNode else {
			// End of program reached (top scope left)
			return
		}
		
		guard let i = parentNode.childNodes.index(where: {
			$0 === currentScopeNode
		}) else {
			throw error(.unbalancedScope)
		}
		
		addCleanupRegistersToCurrentScope()
		addCleanupRegistersToParentScope()
		
		parentNode.childNodes.remove(at: i)
		currentScopeNode = parentNode

	}
	
	public func getCompiledRegister(for varName: String) -> String? {
		
		let deepRegMap = currentScopeNode.deepRegisterMap()
		
		let decompiledVarName = deepRegMap.first(where: { (keyValue: (key: String, value: String)) -> Bool in
			return keyValue.key == varName
		})?.value
		
		return decompiledVarName
	}
	
	func getDecompiledVarName(for register: String) -> String? {
		
		let deepRegMap = currentScopeNode.deepRegisterMap()
		
		let decompiledVarName = deepRegMap.first(where: { (keyValue: (key: String, value: String)) -> Bool in
			return keyValue.value == register
		})?.key
		
		return decompiledVarName
	}
	
	func cleanupRegisterInstructions() -> [BytecodeLine] {
		return cleanupRegisterInstructions(for: currentScopeNode)
	}
	
	private func registersToClean(for scopeNode: ScopeNode) -> [(String, String?)] {

		var registersToCleanup = scopeNode.registerMap.map { (kv) -> (String, String?) in
			return (kv.1, kv.0)
		}
		
		registersToCleanup.append(contentsOf: scopeNode.internalRegisters.map {
			return ($0, nil)
		})
		
		return registersToCleanup
	}
		
	private func cleanupRegisterInstructions(for scopeNode: ScopeNode) -> [BytecodeInstruction] {
		
		var instructions = [BytecodeInstruction]()
	
		for (reg, decompiledVarName) in scopeNode.registersToClean {
			
			// TODO: add compile option (e.g. for release mode) which doesn't add these types of comments
//			let decompiledVarName = getDecompiledVarName(for: reg)
			let label = nextIndexLabel()
			
			var comment = "cleanup"
			
			if let decompiledVarName = decompiledVarName {
				comment += " \(decompiledVarName)"
			}
			
			let instr = BytecodeInstruction(label: label, type: .registerClear, arguments: [reg], comment: comment)
			instructions.append(instr)
			
		}
				
		for (_, key) in scopeNode.registersToClean {
			if let key = key {
				scopeNode.registerMap.removeValue(forKey: key)
			}
		}
		
		scopeNode.internalRegisters.removeAll()
		scopeNode.registersToClean.removeAll()
		
		return instructions
		
	}
	
	// MARK: - Structs
	
	public func getStructMemberId(for memberName: String) -> Int? {
		return structMemberMap[memberName]
	}
	
	public func getStructMemberName(for id: Int) -> String? {
		return structMemberMap.first(where: { (k, v) -> Bool in
			return v == id
		})?.0
	}
	
	// MARK: - Registers
	
	private var registerCount = 0

	/// Get register for var name
	///
	/// - Parameter varName: var name
	/// - Returns: Register and boolean (true = register is new, false = reused)
	func getRegister(for varName: String) -> (String, Bool) {
		
		if let existingReg = currentScopeNode.deepRegisterMap()[varName] {
			return (existingReg, false)
		}
		
		let newReg = getNewRegister()
		currentScopeNode.registerMap[varName] = newReg
		
		return (newReg, true)
	}
	
	func getNewInternalRegisterAndStoreInScope() -> String {

		let newReg = getNewRegister()
		currentScopeNode.internalRegisters.append(newReg)
		
		return newReg
		
	}
	
	private func getNewRegister() -> String {
		registerCount += 1
		let newReg = "r\(registerCount)"
		return newReg
	}
	
	// MARK: - Function ids
	
	// TODO: rename to virtual?
	
	private var functionCount = 0
	
	func getStructId(for structNode: StructNode) -> String {
		
		let name = structNode.prototype.name
		
		if let functionMapped = currentScopeNode.deepFunctionMap()[name] {
			return functionMapped.id
		}
		
		let newReg = getNewFunctionId()
		let exitReg = getNewFunctionId()
		
		currentScopeNode.functionMap[name] = FunctionMapped(id: newReg, exitId: exitReg, returns: true)
		
		return newReg
	}
	
	/// Will make new id if needed
	func getFunctionId(for functionNode: FunctionNode) -> String {
		
		let name = functionNode.prototype.name
		
		if let functionMapped = currentScopeNode.deepFunctionMap()[name] {
			return functionMapped.id
		}
		
		let newReg = getNewFunctionId()
		let exitReg = getNewFunctionId()

		currentScopeNode.functionMap[name] = FunctionMapped(id: newReg, exitId: exitReg, returns: functionNode.prototype.returns)
		
		return newReg
	}
	
	func getExitScopeFunctionId(for functionNode: FunctionNode) throws -> String {
		
		let name = functionNode.prototype.name
		
		guard let functionMapped = currentScopeNode.deepFunctionMap()[name] else {
			throw error(.functionNotFound)
		}
		
		return functionMapped.exitId

	}
	
	/// Expects function id to exist
	func getCallFunctionId(for functionName: String) throws -> String {

		if let functionMapped = currentScopeNode.deepFunctionMap()[functionName] {
			return functionMapped.id
		}
		
		throw error(.functionNotFound)
	}
	
	func doesFunctionReturn(for functionName: String) throws -> Bool {
		
		if let functionMapped = currentScopeNode.deepFunctionMap()[functionName] {
			return functionMapped.returns
		}
	
		throw error(.functionNotFound)

	}
	
	private func getNewFunctionId() -> String {
		functionCount += 1
		let id = "\(functionCount)"
		return id
	}

	// MARK: -
	
	private func error(_ type: CompileError) -> Error {
		return type
	}
	
}
