//
//  ViewController.swift
//  macOS Example
//
//  Created by Louis D'hauwe on 15/10/2016.
//  Copyright © 2016 Silver Fox. All rights reserved.
//

import Cocoa
import Lioness

class ViewController: NSViewController, LionessRunnerDelegate {

	override func viewDidLoad() {
		super.viewDidLoad()
		
		let runner = LionessRunner(logDebug: true)
		runner.delegate = self
		
		let path = stringPath(for: "C")
		
		print(path)

		try! runner.runSource(atPath: path)
		
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
