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
		
		let path = "/Users/louisdhauwe/Desktop/Swift/Lioness/macOS Example/macOS Example/C.lion"
		
		try! runner.runSource(atPath: path)
		
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
