//
//  Lexer.swift
//  Lioness
//
//  Created by Louis D'hauwe on 04/10/2016.
//  Copyright © 2016 Silver Fox. All rights reserved.
//

import Foundation

public class Lexer {
	
	fileprivate static let keywordTokens: [String : Token] = [
		"func": .function,
		"while": .while,
		"if": .if,
		"else": .else,
		"true": .true,
		"false": .false
	]
	
	fileprivate typealias TokenGenerator = (String) -> Token?

	/// The order of this list is important,
	/// e.g. match identifiers before numbers
	fileprivate let tokenList: [(String, TokenGenerator)] = [
		
		// one line comment
		("\\/\\/.*", { _ in .ignoreableToken }),

		// multiline comment
		("/\\*[^*]*\\*+(?:[^/*][^*]*\\*+)*/", { _ in .ignoreableToken }),

		

		("[ \t\n]", { _ in .ignoreableToken }),
		
		("[a-zA-Z][a-zA-Z0-9]*", {
			
			// Prefer keywords over identifiers
			if let t = Lexer.keywordTokens[$0] {
				return t
			} else {
				return .identifier($0)
			}
		}),
		
		// Don't worry about empty matches, tokenize() will ignore those
		("(-?[0-9]*+(,[0-9]+)*(\\.[0-9]+(e-?[0-9]+)?)?)", {
			
			if let f = Double($0) {
				return .number(f)
			}
		
			return nil
		}),
		
		("\\(", { _ in .parensOpen }),
		("\\)", { _ in .parensClose }),
		("\\{", { _ in .curlyOpen }),
		("\\}", { _ in .curlyClose }),
		
		("==", { _ in .comparatorEqual }),
		("!=", { _ in .notEqual }),
		
		("&&", { _ in .booleanAnd }),
		("\\|\\|", { _ in .booleanOr }),
		("!", { _ in .booleanNot }),
		
		(">=", { _ in .comparatorGreaterThanEqual }),
		("<=", { _ in .comparatorLessThanEqual }),
		(">", { _ in .comparatorGreaterThan }),
		("<", { _ in .comparatorLessThan }),
		
		
		("\\+=", { _ in .shortHandAdd }),
		("\\-=", { _ in .shortHandSub }),
		("\\*=", { _ in .shortHandMul }),
		("\\/=", { _ in .shortHandDiv }),
		("\\^=", { _ in .shortHandPow }),

		("=", { _ in .equals }),
		(",", { _ in .comma }),
		
	]
	
	fileprivate let input: String
	
	public init(input: String) {
        self.input = input
    }
	
    public func tokenize() -> [Token] {
		
		var content = input

		var tokenListToUse = [(String, TokenGenerator)]()
		
		for (pattern, generator) in tokenList {
			
			if content.hasMatch(withRegExPattern: pattern) {
				tokenListToUse.append((pattern, generator))
			}
		
		}
	
		
        var tokens = [Token]()
		
        while content.characters.count > 0 {
			
            var matched = false
            
            for (pattern, generator) in tokenListToUse {
				
				if let match = content.firstMatchAtStart(withRegExPattern: pattern) {
					
					if match.isEmpty {
						continue
					}
					
                    if let t = generator(match) {
						
						if case Token.ignoreableToken = t {
						
						} else {
							tokens.append(t)
						}
						
						let index = content.characters.index(content.startIndex, offsetBy: match.characters.count)
						content = content.substring(from: index)
						matched = true
						
						break

					}
					
                }
				
            }

            if !matched {
                let index = content.characters.index(content.startIndex, offsetBy: 1)
                tokens.append(.other(content.substring(to: index)))
                content = content.substring(from: index)
            }
			
        }
		
        return tokens
    }
	
}
