//
//  LionessRunner.swift
//  Lioness
//
//  Created by Louis D'hauwe on 15/10/2016.
//  Copyright © 2016 - 2017 Silver Fox. All rights reserved.
//

import Foundation

public protocol RunnerDelegate {
	
	func log(_ message: String)
	
	func log(_ error: Error)
	
	func log(_ token: Token)
	
}

public enum RunnerError: Error {
	case registerNotFound
	case stdlibFailed
	case runFailed
}

/// Runs through full pipeline, from lexer to interpreter
public class Runner {
	
	fileprivate let logDebug: Bool
	
	fileprivate var source: String?
	
	public var delegate: RunnerDelegate?
	
	let compiler: BytecodeCompiler

	// MARK: -

	public init(logDebug: Bool = false) {
		self.logDebug = logDebug
		compiler = BytecodeCompiler()
	}
	
	public func runSource(at path: String, get varName: String) throws -> Double {
		
		let source = try String(contentsOfFile: path, encoding: .utf8)
		
		return try run(source, get: varName)
	}
	
	func run(_ source: String, get varName: String) throws -> Double {
		
		let stdLib = try StdLib().stdLibCode()
		
		guard let compiledStdLib = compileLionessSourceCode(stdLib) else {
			throw RunnerError.stdlibFailed
		}
		
		guard let compiledSource = compileLionessSourceCode(source) else {
			throw RunnerError.runFailed
		}

		let bytecode = compiledStdLib + compiledSource
		
		let interpreter = try BytecodeInterpreter(bytecode: bytecode)
		try interpreter.interpret()
	
		guard let reg = compiler.getCompiledRegister(for: varName) else {
			throw RunnerError.registerNotFound
		}
		
		do {
			return try interpreter.getRegValue(for: reg)
		} catch {
			throw RunnerError.registerNotFound
		}
	
	}
	
	public func runSource(at path: String) throws {
		
		let source = try String(contentsOfFile: path, encoding: .utf8)
		
		try run(source)
	}
	
	public func run(_ source: String) throws {
		
		let stdLib = try StdLib().stdLibCode()
		
		guard let compiledStdLib = compileLionessSourceCode(stdLib) else {
			throw RunnerError.stdlibFailed
		}
		
		self.source = source
		
		let startTime = CFAbsoluteTimeGetCurrent()
		
		if logDebug {
			logSourceCode(source)
		}
		
		guard let compiledSource = compileLionessSourceCode(source) else {
			throw RunnerError.runFailed
		}

		let fullBytecode = compiledStdLib + compiledSource
		
		let interpretStartTime = CFAbsoluteTimeGetCurrent()

		interpret(fullBytecode)
		
		if logDebug {
			
			let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
			log("\nTotal execution time: \(timeElapsed)s")
			
			let interpretTimeElapsed = CFAbsoluteTimeGetCurrent() - interpretStartTime
			log("\nInterpret execution time: \(interpretTimeElapsed)s")

		}
		
	}
	
	// MARK: -
	
	fileprivate func compileLionessSourceCode(_ source: String) -> BytecodeBody? {
		
		let tokens = runLexer(withSource: source)
		
		guard let ast = parseTokens(tokens) else {
			return nil
		}
		
		guard let bytecode = compileToBytecode(ast: ast) else {
			return nil
		}
		
		return bytecode
		
	}
	
	fileprivate func runLionessSourceCode(_ source: String) {
		
		guard let bytecode = compileLionessSourceCode(source) else {
			return
		}
		
		interpret(bytecode)
		
	}
	
	fileprivate func runLexer(withSource source: String) -> [Token] {
		
		if logDebug {
			logTitle("Start lexer")
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
			logTitle("Start parser")
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
	
	fileprivate func compileToBytecode(ast: [ASTNode]) -> BytecodeBody? {
		
		if logDebug {
			logTitle("Start bytecode compiler")
		}
		
		do {
			
			let bytecode = try compiler.compile(ast)
			
			if logDebug {
				logBytecode(bytecode)
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
	
	fileprivate func interpret(_ bytecode: BytecodeBody) {
		
		if logDebug {
			logTitle("Start bytecode interpreter")
		}
		
		do {
			
			interpreter = try BytecodeInterpreter(bytecode: bytecode)

			try interpreter.interpret()
			
			if logDebug {

				log("Stack at end of execution:\n\(interpreter.stack)\n")

				log("Registers at end of execution:")

				for (key, value) in interpreter.registers {
					
					if let compiledKey = interpreter.regName(for: key),
						let varName = compiler.getDecompiledVarName(for: compiledKey) {
						
						log("\(varName) (\(key)) = \(value)")
						
					} else {
						
						log("\(key) = \(value)")
						
					}
					
				}

			}
			
		} catch {
			
			if logDebug {
				
				log("pc trace:")

				for pc in interpreter.pcTrace {
					log(bytecode[pc].description)
				}
				
				log("\n")

				log(error)
				
			}
			
		}
		
	}
	
	// MARK: -
	// MARK: Logging
	
	fileprivate func logSourceCode(_ source: String) {
		
		logTitle("Source code")
		
		for s in source.components(separatedBy: "\n") {
			log(s)
		}
		
	}
	
	fileprivate func logTitle(_ title: String) {
		
		log("================================")
		log(title)
		log("================================\n")
		
	}
	
	fileprivate func logBytecode(_ bytecode: BytecodeBody) {
		
		var indentLevel = 0
		
		for b in bytecode {
			
			if b is BytecodeEnd || b is BytecodePrivateEnd {
				indentLevel -= 1
			}
			
			var description = ""
			
			if b is BytecodeFunctionHeader || b is BytecodePrivateFunctionHeader {
				description += "\n"
			}
			
			for _ in 0..<indentLevel {
				description += "\t"
			}
			
			description += b.description
			
			if b is BytecodeEnd || b is BytecodePrivateEnd {
				description += "\n"
			}
			
			log(description)
			
			if b is BytecodeFunctionHeader || b is BytecodePrivateFunctionHeader {
				indentLevel += 1
			}
			
		}
		
	}
	
	fileprivate func log(_ message: String) {
		delegate?.log(message)
	}
	
	fileprivate func log(_ error: Error) {
		
		guard let source = source else {
			delegate?.log(error)
			return
		}
		
		if let parseError = error as? ParseError {
			
			let errorDescription = parseError.description(inSource: source)
			delegate?.log(errorDescription)
			
		} else {
			
			delegate?.log(error)

		}
		
	}
	
	fileprivate func log(_ token: Token) {
		delegate?.log(token)
	}
	
}
