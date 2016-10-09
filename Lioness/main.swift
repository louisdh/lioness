//
//  main.swift
//  Lioness
//
//  Created by Louis D'hauwe on 04/10/2016.
//  Copyright © 2016 Silver Fox. All rights reserved.
//

import Foundation


class Lioness {
	
	func runSource(atPath path: String) {
		
		let source = try! String(contentsOfFile: path, encoding: .utf8)
		
		runSource(source)
	}
	
	func runSource(_ source: String) {
		
		let startTime = CFAbsoluteTimeGetCurrent()

		print("================================")
		print("Source code")
		print("================================\n")

		for s in source.components(separatedBy: "\n") {
			print(s)
		}

		print("\n================================")
		print("Start lexer")
		print("================================\n")

		let lexer = Lexer(input: source)
		let tokens = lexer.tokenize()

		print("Number of tokens: \(tokens.count)")

		for t in tokens {
			print(t)
		}



		print("\n================================")
		print("Start parser")
		print("================================\n")

		let parser = Parser(tokens: tokens)

		var ast: [ASTNode]? = nil

		do {

			ast = try parser.parse()
			
			print("Parsed AST:")

			if let ast = ast {
				for a in ast {
					print(a.description)
				}
			}
			
		} catch {
			print(error)
		}



		print("\n================================")
		print("Start bytecode compiler")
		print("================================\n")

		guard let astParsed = ast else {
			return
		}
		

		let bytecodeCompiler = BytecodeCompiler(ast: astParsed)

		var bytecode: [BytecodeInstruction]? = nil

		do {

			bytecode = try bytecodeCompiler.compile()

			if let bytecode = bytecode {
				for b in bytecode {
					print(b.description)
				}
			}

		} catch {
			
			print(error)
			
		}

		guard let bytecodeCompiled = bytecode else {
			return
		}

		print("\n================================")
		print("Start bytecode interpreter")
		print("================================\n")
		
		let interpreter = BytecodeInterpreter(bytecode: bytecodeCompiled)
		
		do {

			try interpreter.interpret()

		} catch {
		
			print(error)

		}
		
		let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
		print("\nTotal execution time: \(timeElapsed)ms")
		
	}

}

let lioness = Lioness()
lioness.runSource(atPath: "/Users/louisdhauwe/Desktop/Swift/Lioness/Lioness/A.lion")

