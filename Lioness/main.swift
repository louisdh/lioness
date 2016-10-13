//
//  main.swift
//  Lioness
//
//  Created by Louis D'hauwe on 04/10/2016.
//  Copyright © 2016 Silver Fox. All rights reserved.
//

import Foundation


class Lioness {
	
	fileprivate var printDebug: Bool
	
	init(printDebug: Bool = false) {
		self.printDebug = printDebug
	}
	
	func runSource(atPath path: String) throws {
		
		let source = try String(contentsOfFile: path, encoding: .utf8)
		
		runSource(source)
	}
	
	func runSource(_ source: String) {
		
		let startTime = CFAbsoluteTimeGetCurrent()

		if printDebug {
			printSourceCode(source)
		}
		
		runLionessSourceCode(source)
		
		if printDebug {

			let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
			print("\nTotal execution time: \(timeElapsed)ms")
			
		}
		
	}
	
	fileprivate func runLionessSourceCode(_ source: String) {
		
		let tokens = runLexer(withSource: source)
		
		guard let ast = parseTokens(tokens) else {
			return
		}
		
		guard let bytecode = compileToBytecode(ast: ast) else {
			return
		}
		
		interpretBytecode(bytecode)
		
	}
	
	fileprivate func printSourceCode(_ source: String) {
		
		print("================================")
		print("Source code")
		print("================================\n")
		
		for s in source.components(separatedBy: "\n") {
			print(s)
		}
		
	}

	fileprivate func runLexer(withSource source: String) -> [Token] {
		
		if printDebug {

			print("\n================================")
			print("Start lexer")
			print("================================\n")
			
		}
		
		let lexer = Lexer(input: source)
		let tokens = lexer.tokenize()
		
		if printDebug {

			print("Number of tokens: \(tokens.count)")
			
			for t in tokens {
				print(t)
			}

		}
		
		return tokens
		
	}
	
	fileprivate func parseTokens(_ tokens: [Token]) -> [ASTNode]? {
		
		if printDebug {
			print("\n================================")
			print("Start parser")
			print("================================\n")
		}
		
		let parser = Parser(tokens: tokens)
		
		var ast: [ASTNode]? = nil
		
		do {
			
			ast = try parser.parse()
			
			if printDebug {

				print("Parsed AST:")
				
				if let ast = ast {
					for a in ast {
						print(a.description)
					}
				}
				
			}
			
			return ast
			
		} catch {
		
			if printDebug {
				print(error)
			}
			
			return nil

		}
		
	}
	
	fileprivate func compileToBytecode(ast: [ASTNode]) -> [BytecodeInstruction]? {
		
		if printDebug {

			print("\n================================")
			print("Start bytecode compiler")
			print("================================\n")

		}
		
		let bytecodeCompiler = BytecodeCompiler(ast: ast)
		
		var bytecode: [BytecodeInstruction]? = nil
		
		do {
			
			bytecode = try bytecodeCompiler.compile()
			
			if printDebug {

				if let bytecode = bytecode {
					for b in bytecode {
						print(b.description)
					}
				}
				
			}
			
			return bytecode
			
		} catch {
			
			if printDebug {

				print(error)

			}
			
			return nil
			
		}
		
	}
	
	fileprivate func interpretBytecode(_ bytecode: [BytecodeInstruction]) {
		
		if printDebug {

			print("\n================================")
			print("Start bytecode interpreter")
			print("================================\n")

		}
		
		let interpreter = BytecodeInterpreter(bytecode: bytecode)
		
		do {
			
			try interpreter.interpret()
			
		} catch {
			
			if printDebug {

				print(error)

			}
			
		}
		
	}
	
}

let lioness = Lioness(printDebug: true)
try lioness.runSource(atPath: "/Users/louisdhauwe/Desktop/Swift/Lioness/Lioness/C.lion")

