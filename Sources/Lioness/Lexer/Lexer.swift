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
	private var currentStringLength = 0

	private var tokens = [Token]()

	public init(input: String) {
        self.input = input
		content = input
    }
	
	var nextString: String {
		
		let firstChar = content.characters.first
		
		let nextString: String
		
		if let firstChar = firstChar {
			nextString = currentString.appending("\(firstChar)")
		} else {
			nextString = currentString
		}
		
		return nextString
	}

	public func tokenize() -> [Token] {

		content = input

		isInLineComment = false
		isInBlockComment = false

		charIndex = 0

		currentString = ""
		currentStringLength = 0
		
		tokens = [Token]()

		var canDoExtraRun = true

		while !content.isEmpty || canDoExtraRun {

			if content.isEmpty {
				canDoExtraRun = false
			}

//			print("current: \(currentString)")

			var removedControlChar = false

			while removeControlChar() {

				removedControlChar = true
			}

			if content.isEmpty {
				// EOF
				removedControlChar = true
			}

			let isEOF = content.isEmpty

			if isCurrentStringValidNumber || (!removedControlChar && isStringValidNumber(nextString)) {
				isInNumber = true
//				print(nextString)
//				print("isInNumber = true")
			}

			if !isInLineComment && currentString == "//" {
				isInLineComment = true
				continue
			}
			
			if !isInBlockComment && currentString == "/*" {
				isInBlockComment = true
				continue
			}
			
			if currentString.isEmpty && !isInNumber && (!isInLineComment && content.hasPrefix("//")) {
				
				isInLineComment = true
				consumeCharactersAtStart(2)
				continue
				
			}
			
			
			
			if currentString.isEmpty && !isInNumber && (!isInBlockComment && content.hasPrefix("/*")) {

				isInBlockComment = true
				consumeCharactersAtStart(2)
				continue
			}

			if !isInBlockComment && !isInLineComment {

				
				
				if isInNumber {

					if !isStringValidNumber(nextString) || isEOF || removedControlChar {
						if let f = NumberType(currentString) {
							addToken(type: .number(f))

							isInNumber = false

							if let nextChar = content.characters.first {
								if currentString == "/" {
									if nextChar == "/" ||  nextChar == "*" {
										consumeCharactersAtStart(1)
										continue
									}
								}
							}
							
							if !content.isEmpty {
								continue
							}

						}

						isInNumber = false

					} else {

						if !content.isEmpty {
							consumeCharactersAtStart(1)
						}

						if let nextChar = content.characters.first {
							if currentString == "/" {
								if nextChar == "/" ||  nextChar == "*" {
									consumeCharactersAtStart(1)
								}
							}
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

			}
			
			if !isInLineComment && nextString == "//" {
				
				isInLineComment = true
				consumeCharactersAtStart(1)
				continue
				
			}
			
			if !isInBlockComment && nextString == "/*" {
				
				isInLineComment = true
				consumeCharactersAtStart(1)
				continue
				
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
		if str.isEmpty || str == "-" {
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
				
				if keyword == "\n" {
					
					if isInLineComment {
						
						isInLineComment = false
						addToken(type: .comment)
						
					}
					
				}

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

		if let type = Lexer.keywordTokens[currentString] {
			addToken(type: type)
			
			return true
		}
		
		return false
	}

	func isStringTwoCharToken(_ str: String) -> Bool {

		if let _ = Lexer.twoCharTokensMapping[str] {
			return true
		}

		return false

	}

	func tokenizeTwoChar() -> Bool {

		if let type = Lexer.twoCharTokensMapping[currentString] {
			addToken(type: type)
			
			return true
		}

		return false
	}

	func tokenizeOneChar() -> Bool {

		if let type = Lexer.otherMapping[currentString] {
			addToken(type: type)
			
			return true
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

		let start = charIndex - currentStringLength
		let end = charIndex
		
		let range: Range<Int> = start..<end

		let token = Token(type: type, range: range)

		tokens.append(token)

		currentString = ""
		currentStringLength = 0

	}

	func consumeCharactersAtStart(_ n: Int) {

		let index = content.characters.index(content.startIndex, offsetBy: n)

		currentString += content.substring(to: index)
		currentStringLength += n
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
