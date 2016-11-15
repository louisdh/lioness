//
//  LionessRunner.swift
//  Lioness
//
//  Created by Louis D'hauwe on 15/10/2016.
//  Copyright © 2016 Silver Fox. All rights reserved.
//

import Foundation

public protocol RunnerDelegate {
	
	func log(_ message: String)
	
	func log(_ error: Error)
	
	func log(_ token: Token)
	
}

/// Runs through full pipeline, from lexer to interpreter
public class Runner {
	
	fileprivate var logDebug: Bool
	
	fileprivate var source: String?
	
	public var delegate: RunnerDelegate?
	
	// MARK: -

	public init(logDebug: Bool = false) {
		self.logDebug = logDebug
	}
	
	public func runSource(atPath path: String) throws {
		
		let source = try String(contentsOfFile: path, encoding: .utf8)
		
		runSource(source)
	}
	
	public func runSource(_ source: String) {
		
		self.source = source
		
		let startTime = CFAbsoluteTimeGetCurrent()
		
		if logDebug {
			logSourceCode(source)
		}
		
		runLionessSourceCode(source)
		
		if logDebug {
			
			let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
			log("\nTotal execution time: \(timeElapsed)s")
			
		}
		
	}
	
	// MARK: -
	
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
	
	fileprivate func logSourceCode(_ source: String) {
		
		log("================================")
		log("Source code")
		log("================================\n")
		
		for s in source.components(separatedBy: "\n") {
			log(s)
		}
		
	}
	
	fileprivate func runLexer(withSource source: String) -> [Token] {
		
		if logDebug {
			
			log("\n================================")
			log("Start lexer")
			log("================================\n")
			
		}
		
		let lexer = Lexer(input: source)
		let tokens = lexer.tokenize()
		
		if logDebug {
			
			log("Number of tokens: \(tokens.count)")
			
			for t in tokens {
				log(t)
			}
			
		}
		
		return tokens
		
	}
	
	fileprivate func parseTokens(_ tokens: [Token]) -> [ASTNode]? {
		
		if logDebug {
			log("\n================================")
			log("Start parser")
			log("================================\n")
		}
		
		let parser = Parser(tokens: tokens)
		
		var ast: [ASTNode]? = nil
		
		do {
			
			ast = try parser.parse()
			
			if logDebug {
				
				log("Parsed AST:")
				
				if let ast = ast {
					for a in ast {
						log(a.description)
					}
				}
				
			}
			
			return ast
			
		} catch {
			
			if logDebug {
				log(error)
			}
			
			return nil
			
		}
		
	}
	
	fileprivate func compileToBytecode(ast: [ASTNode]) -> [BytecodeInstruction]? {
		
		if logDebug {
			
			log("\n================================")
			log("Start bytecode compiler")
			log("================================\n")
			
		}
		
		let bytecodeCompiler = BytecodeCompiler(ast: ast)
		
		var bytecode: [BytecodeInstruction]? = nil
		
		do {
			
			bytecode = try bytecodeCompiler.compile()
			
			if logDebug {
				
				if let bytecode = bytecode {
					for b in bytecode {
						log(b.description)
					}
				}
				
			}
			
			return bytecode
			
		} catch {
			
			if logDebug {
				
				log(error)
				
			}
			
			return nil
			
		}
		
	}
	
	var interpreter: BytecodeInterpreter!
	
	fileprivate func interpretBytecode(_ bytecode: [BytecodeInstruction]) {
		
		if logDebug {
			
			log("\n================================")
			log("Start bytecode interpreter")
			log("================================\n")
			
		}
		
		interpreter = BytecodeInterpreter(bytecode: bytecode)
		
		do {
			
			try interpreter.interpret()
			
			if logDebug {

				log("Stack at end of execution:\n\(interpreter.stack)")
				log("Registers at end of execution:\n\(interpreter.registers)")

			}
			
		} catch {
			
			if logDebug {
				
				log(error)
				
			}
			
		}
		
	}
	
	// MARK: -
	// MARK: Logging
	
	fileprivate func log(_ message: String) {
		delegate?.log(message)
	}
	
	fileprivate func log(_ error: Error) {
		
		guard let source = source else {
			delegate?.log(error)
			return
		}
		
		if let error = error as? ParseError {
			
			let errorDescription = error.description(inSource: source)
			delegate?.log(errorDescription)
			
		} else {
			
			delegate?.log(error)

		}
		
	}
	
	fileprivate func log(_ token: Token) {
		delegate?.log(token)
	}
	
}
