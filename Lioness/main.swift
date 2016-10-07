//
//  main.swift
//  Lioness
//
//  Created by Louis D'hauwe on 04/10/2016.
//  Copyright © 2016 Silver Fox. All rights reserved.
//

import Foundation

let source = multiline(
	"def foo(x, y)",
	"  x + y * 2 + (4 + 5)^3 / 3",
	"  x + y",
	"",
	"def bar(a, b)",
	"  15 * 8",
	"",
	"foo(3, 4)"
)


//let source = multiline(
//	"1 + 2"
//)




let lexer = Lexer(input: source)
let tokens = lexer.tokenize()

print("Number of tokens: \(tokens.count)")

for t in tokens {
	print(t)
}

print("================================")

let parser = Parser(tokens: tokens)

do {
	
	let ast = try parser.parse()
	
	for a in ast {
		print(a.description)
	}
	
} catch {
	print(error)
}
