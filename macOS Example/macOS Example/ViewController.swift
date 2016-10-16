//
//  ViewController.swift
//  macOS Example
//
//  Created by Louis D'hauwe on 15/10/2016.
//  Copyright © 2016 Silver Fox. All rights reserved.
//

import Cocoa
import Lioness

class ViewController: NSViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		
		let lioness = LionessRunner(logDebug: true)
		try! lioness.runSource(atPath: "/Users/louisdhauwe/Desktop/Swift/Lioness/macOS Example/macOS Example/C.lion")
		
	}

	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}

}
