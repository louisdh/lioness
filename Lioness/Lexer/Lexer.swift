//
//  Lexer.swift
//  Lioness
//
//  Created by Louis D'hauwe on 04/10/2016.
//  Copyright © 2016 - 2017 Silver Fox. All rights reserved.
//

import Foundation

public class Lexer {

	private static let keywordTokens: [String : TokenType] = [
		"func": .function,
		"while": .while,
		"for": .for,
		"if": .if,
		"else": .else,
		"true": .true,
		"false": .false,
		"continue": .continue,
		"break": .break,
		"do": .do,
		"times": .times,
		"repeat": .repeat,
		"return": .return,
		"returns": .returns,
		"struct": .struct
	]

	/// Currently only works for 1 char tokens
	private static let otherMapping: [String : TokenType] = [
		"(": .parensOpen,
		")": .parensClose,
		"{": .curlyOpen,
		"}": .curlyClose,
		",": .comma,
		".": .dot,
		"!": .booleanNot,
		">": .comparatorGreaterThan,
		"<": .comparatorLessThan,
		"=": .equals
	]

	private static let ignorableMapping: [String : TokenType] = [
		"\t": .ignoreableToken,
		"\n": .ignoreableToken,
		" ": .ignoreableToken,
	]
	
	private static let twoCharTokensMapping: [String : TokenType] = [
		"==": .comparatorEqual,
		"!=": .notEqual,
		
		"&&": .booleanAnd,
		"||": .booleanOr,
		
		">=": .comparatorGreaterThanEqual,
		"<=": .comparatorLessThanEqual,
		
		"+=": .shortHandAdd,
		"-=": .shortHandSub,
		"*=": .shortHandMul,
		"/=": .shortHandDiv,
		"^=": .shortHandPow
	
	]
	
	private static let reservedOneCharIdentifiers: [String] = ["+", "-", "/", "*", "^"]
	
	lazy var invalidIdentifierCharSet: CharacterSet = {
		
		var chars = "-."
		
		reservedOneCharIdentifiers.forEach {
			chars.append($0)
		}
		
		otherMapping.keys.forEach {
			chars.append($0)
		}
		
		return CharacterSet(charactersIn: chars)
		
	}()
	
	lazy var validIdentifierCharSet: CharacterSet = {
		return self.invalidIdentifierCharSet.inverted
	}()

	let validNumberCharSet = CharacterSet(charactersIn: "0123456789.e-")

	private let input: String
	private var content: String

	private var isInLineComment = false
	private var isInBlockComment = false
	private var isInIdentifier = false
	private var isInNumber = false
	
	private var charIndex = 0
	
	private var currentString = ""
	
	private var tokens = [Token]()
	
	public init(input: String) {
        self.input = input
		content = input
    }
		
	public func tokenize() -> [Token] {
		
		content = input

		isInLineComment = false
		isInBlockComment = false
		
		charIndex = 0

		currentString = ""
		
		tokens = [Token]()

		var canDoExtraRun = true
		
		while !content.isEmpty || canDoExtraRun {
			
			if content.isEmpty {
				canDoExtraRun = false
			}
			
//			print("current: \(currentString)")
			
			let firstChar = content.characters.first
			
			let nextString: String

			if let firstChar = firstChar {
				nextString = currentString.appending("\(firstChar)")
			} else {
				nextString = currentString
			}
			
			var removedControlChar = false
			
			if removeNewLineControlChar() {
				removedControlChar = true
				
				if isInLineComment {
					
					isInLineComment = false
					addToken(type: .comment)

				}
			}
			
			while removeControlChar() {
				
				removedControlChar = true
			}
			
			if content.isEmpty {
				// EOF
				removedControlChar = true
			}
			
			let isEOF = content.isEmpty
			
			if isCurrentStringValidNumber || isStringValidNumber(nextString) {
				isInNumber = true
			}

			if !isInBlockComment && content.hasPrefix("/*") {
				
				isInBlockComment = true
				consumeCharactersAtStart(2)
				continue
			}
			
			if !isInBlockComment && !isInLineComment {
			
				if isInNumber {
					
					if !isStringValidNumber(nextString) || isEOF {
						if let f = NumberType(currentString) {
							addToken(type: .number(f))
							
							if !content.isEmpty {
								consumeCharactersAtStart(1)
							}
							
							continue

						}
						
						isInNumber = false
						
					} else {
						
						if !content.isEmpty {
							consumeCharactersAtStart(1)
						}
						
						continue
						
					}
					
				}
				
				if tokenizeTwoChar() {
					continue
				}
				
				if isStringTwoCharToken(nextString) {
					
					if !content.isEmpty {
						consumeCharactersAtStart(1)
					}
					
					continue
				}
				
				if tokenizeReservedOneChar() {
					continue
				}
				
				if tokenizeOneChar() {
					continue
				}
				
				if (removedControlChar || (isStringValidKeyword(currentString) && !isStringValidKeyword(nextString))) && !currentString.isEmpty {
					
					if tokenizeKeyword() {
						continue
					}
					
					addIdentifierToken()
					
					continue
				}
				
				if isCurrentStringValidIdentifier && !isStringValidIdentifier(nextString) {
					addIdentifierToken()
					
					continue
				}
				
				if content.hasPrefix("//") {
					
					isInLineComment = true
					consumeCharactersAtStart(2)
					continue
					
				}
			
			}
			
			if content.hasPrefix("*/") {
				
				consumeCharactersAtStart(2)
				isInBlockComment = false
				addToken(type: .comment)
				continue

			} else if isInBlockComment {
				

			}
			
			if !content.isEmpty {
				consumeCharactersAtStart(1)
			} else if isInBlockComment || isInLineComment {
				addToken(type: .comment)
			}

		}
		
		return tokens
	}
	
	func isStringValidKeyword(_ str: String) -> Bool {
		return Lexer.keywordTokens.keys.contains(str)
	}
	
	var isCurrentStringValidIdentifier: Bool {
		return isStringValidIdentifier(currentString)
	}
	
	func isStringValidIdentifier(_ str: String) -> Bool {
		if str.isEmpty {
			return false
		}
		return str.rangeOfCharacter(from: validIdentifierCharSet.inverted) == nil
	}
	
	var isCurrentStringValidNumber: Bool {
		return isStringValidNumber(currentString)
	}
	
	func isStringValidNumber(_ str: String) -> Bool {
		if str.isEmpty {
			return false
		}
		return str.rangeOfCharacter(from: validNumberCharSet.inverted) == nil
	}
	
	func addIdentifierToken() {
		
		addToken(type: .identifier(currentString))

	}
	
	func removeNewLineControlChar() -> Bool {
		
		let keyword = "\n"
		
		if content.hasPrefix(keyword) {
			
			let temp = currentString
			let keywordLength = keyword.characters.count
			consumeCharactersAtStart(keywordLength)
			currentString = temp
			
			return true
		}
		
		return false
	}
	
	func removeControlChar() -> Bool {
		
		for (keyword, _) in Lexer.ignorableMapping {
			
			if content.hasPrefix(keyword) {
				
				let temp = currentString
				let keywordLength = keyword.characters.count
				consumeCharactersAtStart(keywordLength)
				currentString = temp
				
				return true
			}
			
		}
		
		return false
	}
	
	func tokenizeKeyword() -> Bool {

		for (keyword, type) in Lexer.keywordTokens {
			
			if currentString == keyword {

				addToken(type: type)
				
				return true
			}
			
		}
		
		return false
	}
	
	func isStringTwoCharToken(_ str: String) -> Bool {
		
		for (keyword, _) in Lexer.twoCharTokensMapping {
			
			if str == keyword {
				return true
			}
			
		}
		
		return false
		
	}
	
	func tokenizeTwoChar() -> Bool {
		
		for (keyword, type) in Lexer.twoCharTokensMapping {
			
			if currentString == keyword {
				
				addToken(type: type)
				
				return true
			}
			
		}
		
		return false
	}
	
	func tokenizeOneChar() -> Bool {
		
		for (keyword, type) in Lexer.otherMapping {
			
			if currentString == keyword {
				
				addToken(type: type)
				
				return true
			}
			
		}
		
		return false
	}
	
	func tokenizeReservedOneChar() -> Bool {
		
		for keyword in Lexer.reservedOneCharIdentifiers {
			
			if currentString == keyword {
				
				addToken(type: .other(keyword))
				
				return true
			}
			
		}
		
		return false
	}
	
	
	
	func addToken(type: TokenType) {
		
		let keywordLength = currentString.characters.count
		
		let start = input.index(input.startIndex, offsetBy: charIndex - keywordLength)
		let end = input.index(start, offsetBy: keywordLength)
		let range = start..<end
		
		let token = Token(type: type, range: range)
		
		tokens.append(token)
		
		currentString = ""
		
	}
	
	func consumeCharactersAtStart(_ n: Int) {
		
		let index = content.characters.index(content.startIndex, offsetBy: n)
		
		currentString += content.substring(to: index)
		charIndex += n
		content.removeCharactersAtStart(n)
		
	}

}

extension String {
	
	mutating func removeCharactersAtStart(_ n: Int) {
		
		let index = self.characters.index(self.startIndex, offsetBy: n)
		self = self.substring(from: index)
		
	}
	
}
