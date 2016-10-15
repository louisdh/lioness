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
		"true": .true,
		"false": .false
	]
	
	fileprivate typealias TokenGenerator = (String) -> Token?

	fileprivate let tokenList: [(String, TokenGenerator)] = [
		("[ \t\n]", { _ in nil }),
		
		("[a-zA-Z][a-zA-Z0-9]*", {
			
			// Prefer keywords over identifiers
			if let t = Lexer.keywordTokens[$0] {
				return t
			} else {
				return .identifier($0)
			}
		}),
		
		// Don't worry about empty matches, tokenize() will ignore those
		("(-?[0-9]?+(,[0-9]+)*(\\.[0-9]+(e-?[0-9]+)?)?)", { (r: String) in .number(Float(r) ?? 0.0) }),
		
		("\\(", { _ in .parensOpen }),
		("\\)", { _ in .parensClose }),
		("\\{", { _ in .curlyOpen }),
		("\\}", { _ in .curlyClose }),
		
		("==", { _ in .comparatorEqual }),
		("!=", { _ in .notEqual }),
		
		(">", { _ in .comparatorGreaterThan }),
		("<", { _ in .comparatorLessThan }),
		(">=", { _ in .comparatorGreaterThanEqual }),
		("<=", { _ in .comparatorLessThanEqual }),
		
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
		
        var tokens = [Token]()
        var content = input
        
        while content.characters.count > 0 {
			
            var matched = false
            
            for (pattern, generator) in tokenList {
				
				if let m = content.firstMatch(withRegExPattern: pattern) {
					
					if m.isEmpty {
						continue
					}
					
                    if let t = generator(m) {
                        tokens.append(t)
                    }

                    content = content.substring(from: content.characters.index(content.startIndex, offsetBy: m.characters.count))
                    matched = true
                    break
					
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
