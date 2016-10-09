//
//  BytecodeInterpreter.swift
//  Lioness
//
//  Created by Louis D'hauwe on 09/10/2016.
//  Copyright © 2016 Silver Fox. All rights reserved.
//

import Foundation

public class BytecodeInterpreter {
	
	fileprivate let bytecode: [BytecodeInstruction]
	fileprivate var index = 0
	
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
			
			if instruction.command == "load_const" {
				pc = executeLoadConst(instruction, pc: pc)
			}
			
			if instruction.command == "add" {
				pc = executeAdd(pc: pc)
			}
			
			if instruction.command == "sub" {
				pc = executeSub(pc: pc)
			}
			
			if instruction.command == "mul" {
				pc = executeMul(pc: pc)
			}
			
			if instruction.command == "div" {
				pc = executeDiv(pc: pc)
			}
		
		}
		
		print("Stack at end of execution:\n\(stack)")
		
	}

	func executeLoadConst(_ instruction: BytecodeInstruction, pc: Int) -> Int {
		push(Float(instruction.arguments.first!)!)
		return pc + 1
	}
	
	func executeAdd(pc: Int) -> Int {
		
		let lhs = pop()
		let rhs = pop()
		
		push(lhs + rhs)
		
		return pc + 1
	}
	
	func executeSub(pc: Int) -> Int {
		
		let lhs = pop()
		let rhs = pop()
		
		push(lhs - rhs)
		
		return pc + 1
	}
	
	func executeMul(pc: Int) -> Int {
		
		let lhs = pop()
		let rhs = pop()
		
		push(lhs * rhs)
		
		return pc + 1
	}
	
	func executeDiv(pc: Int) -> Int {
		
		let rhs = pop()
		let lhs = pop()

		push(lhs / rhs)
		
		return pc + 1
	}
	
	func pop() -> Float {
		let last = stack.removeLast()
		return last
	}
	
	func push(_ item: Float) {
		stack.append(item)
	}

}
