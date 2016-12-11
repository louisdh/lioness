//
//  BytecodeCompiler.swift
//  Lioness
//
//  Created by Louis D'hauwe on 07/10/2016.
//  Copyright © 2016 Silver Fox. All rights reserved.
//

import Foundation

/// Scorpion Bytecode Compiler
public class BytecodeCompiler {
	
	// MARK: - Private
	
	fileprivate let ast: [ASTNode]
	fileprivate var index: UInt = 0
	
	fileprivate var loopScopeStartStack = [String]()
	fileprivate var loopHeaderStack = [String]()
	fileprivate var loopContinueStack = [String]()

	fileprivate let scopeTreeRoot: ScopeNode

	fileprivate var currentScopeNode: ScopeNode

	
	// MARK: -

	public init(ast: [ASTNode]) {
		self.ast = ast
		scopeTreeRoot = ScopeNode(childNodes: [])
		currentScopeNode = scopeTreeRoot
	}
	
	// MARK: - Public
	
	public func compile() throws -> BytecodeBody {
		
		currentScopeNode = scopeTreeRoot
		
		var bytecode = BytecodeBody()

		for node in ast {
			
			let compiled = try node.compile(with: self)
			bytecode.append(contentsOf: compiled)
			
		}
		
		return bytecode
	}
	
	// MARK: - Labels

	func nextIndexLabel() -> String {
		index += 1
		return "\(index)"
	}
	
	func peekNextIndexLabel() -> String {
		return "\(index + 1)"
	}
	
	// TODO: make stack operations throw?

	// MARK: - Loop header
	
	func pushLoopHeader(_ label: String) {
		loopHeaderStack.append(label)
	}
	
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
	
	// MARK: - Scope tree

	func enterNewScope() {
		
		let newScopeNode = ScopeNode(parentNode: currentScopeNode, childNodes: [])
		currentScopeNode.childNodes.append(newScopeNode)
		currentScopeNode = newScopeNode
		
	}

	func leaveCurrentScope() throws -> BytecodeBody {
		
		guard let parentNode = currentScopeNode.parentNode else {
			// End of program reached (top scope left)
			return []
		}
		
		guard let i = parentNode.childNodes.index(where: { (s) -> Bool in
			return s === currentScopeNode
		}) else {
			
			// TODO: throw error
			return []
		}
		
		let cleanupInstructions = cleanupRegisterInstructions(for: currentScopeNode)
		
		parentNode.childNodes.remove(at: i)
		currentScopeNode = parentNode

		return cleanupInstructions
	}
	
	fileprivate func cleanupRegisterInstructions(for scopeNode: ScopeNode) -> BytecodeBody {
		
		var instructions = BytecodeBody()
		
		var registersToCleanup = scopeNode.registerMap.map { $0.1 }
		
		registersToCleanup.append(contentsOf: scopeNode.internalRegisters)
		
		for reg in registersToCleanup {
			
			let label = nextIndexLabel()
			let instr = BytecodeInstruction(label: label, type: .registerClear, arguments: [reg])
			instructions.append(instr)
			
		}
		
		return instructions
		
	}
	
	// MARK: - Registers
	
	fileprivate var registerCount = 0

	func getRegister(for varName: String) -> String {
		
		if let existingReg = currentScopeNode.deepRegisterMap()[varName] {
			return existingReg
		}
		
		let newReg = getNewRegister()
		currentScopeNode.registerMap[varName] = newReg
		
		return newReg
	}
	
	func getNewInternalRegisterAndStoreInScope() -> String {

		let newReg = getNewRegister()
		currentScopeNode.internalRegisters.append(newReg)
		
		return newReg
		
	}
	
	fileprivate func getNewRegister() -> String {
		registerCount += 1
		let newReg = "r\(registerCount)"
		return newReg
	}
	
	// MARK: - Function ids
	
	fileprivate var functionCount = 0
	
	func getFunctionId(for functionName: String) -> String {
		
		if let existingReg = currentScopeNode.deepFunctionMap()[functionName] {
			return existingReg
		}
		
		let newReg = getNewFunctionId()
		currentScopeNode.functionMap[functionName] = newReg
		
		return newReg
	}
	
	fileprivate func getNewFunctionId() -> String {
		functionCount += 1
		let id = "\(functionCount)"
		return id
	}

	
}
