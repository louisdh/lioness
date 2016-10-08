//
//  Lexer.swift
//  Lioness
//
//  Created by Louis D'hauwe on 04/10/2016.
//  Copyright © 2016 Silver Fox. All rights reserved.
//

import Foundation

public enum Token {
    case ifStatement
    case identifier(String)
    case number(Float)
    case parensOpen
    case parensClose
	case curlyOpen
	case curlyClose
    case comma
	case equals
	case plus
	case function
    case other(String)
}

open class Lexer {
	
	typealias TokenGenerator = (String) -> Token?
	
	fileprivate let tokenList: [(String, TokenGenerator)] = [
		("[ \t\n]", { _ in nil }),
		
		// Prefer keywords over identifiers
		
		("[a-zA-Z][a-zA-Z0-9]*", { $0 == "func" ? .function : .identifier($0) }),

//		("[a-zA-Z][a-zA-Z0-9]*", { $0 == "if" ? .ifStatement : .identifier($0) }),

		("[0-9.]+", { (r: String) in .number((r as NSString).floatValue) }),
		("\\(", { _ in .parensOpen }),
		("\\)", { _ in .parensClose }),
		("\\{", { _ in .curlyOpen }),
		("\\}", { _ in .curlyClose }),
		("=", { _ in .equals }),
//		("\\+", { _ in .plus }),
		(",", { _ in .comma }),
	]
	
	fileprivate let input: String
	
	init(input: String) {
        self.input = input
    }
	
    open func tokenize() -> [Token] {
		
        var tokens = [Token]()
        var content = input
        
        while content.characters.count > 0 {
			
            var matched = false
            
            for (pattern, generator) in tokenList {
				
                if let m = content.match(pattern) {
					
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
