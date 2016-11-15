//
//  ViewController.swift
//  macOS Example
//
//  Created by Louis D'hauwe on 15/10/2016.
//  Copyright © 2016 Silver Fox. All rights reserved.
//

import Cocoa
import Lioness

class ViewController: NSViewController, RunnerDelegate {

	override func viewDidLoad() {
		super.viewDidLoad()
		
		let runner = Runner(logDebug: true)
		runner.delegate = self
		
		let path = stringPath(for: "A")
		
		print(path)

		try! runner.runSource(atPath: path)
		
//		drawASTGraph(for: "A")
	}
	
	func drawASTGraph(for testFile: String) {
		
		let path = stringPath(for: testFile)
		
		let source = try! String(contentsOfFile: path, encoding: .utf8)

		let lexer = Lexer(input: source)
		let tokens = lexer.tokenize()
		
		let parser = Parser(tokens: tokens)
		let ast = try! parser.parse()

		let visualizer = ASTVisualizer(body: BodyNode(nodes: ast))
		
		if let image = visualizer.draw() {
			print(image)
		}
		
		
	}
	
	/// Load .lion file in resources of "macOS Example" target
	fileprivate func stringPath(for testFile: String) -> String {
	
		let fileManager = FileManager.default
		
		let current = fileManager.currentDirectoryPath
		let resources = "\(current)/macOS Example.app/Contents/Resources/"
		let path = "\(resources)\(testFile).lion"
		
		return path
	}

	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}
	
	// MARK: -
	// MARK: Lioness Runner Delegate

	@nonobjc func log(_ message: String) {
		print(message)
	}
	
	@nonobjc func log(_ error: Error) {
		
		print(error)
	}
	
	@nonobjc func log(_ token: Token) {
		print(token)
	}
	
}
