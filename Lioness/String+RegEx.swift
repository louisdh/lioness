//
//  Regex.swift
//  Lioness
//
//  Created by Louis D'hauwe on 04/10/2016.
//  Copyright © 2016 - 2017 Silver Fox. All rights reserved.
//

import Foundation

//var expressions = [String : NSRegularExpression]()

extension String {
	
	/// First match at start of string (will add "^" to front of pattern)
	func firstMatchAtStart(withRegExPattern pattern: String) -> String? {

//        if let exists = expressions[pattern] {
//			return firstMatch(withRegEx: exists)
//        }
		
		guard let expression = try? NSRegularExpression(pattern: "^\(pattern)", options: []) else {
			return nil
		}
		
//		expressions[pattern] = expression
		
		return firstMatch(withRegEx: expression)
    }
	
	func hasMatch(withRegExPattern pattern: String) -> Bool {

		guard let expression = try? NSRegularExpression(pattern: "\(pattern)", options: []) else {
			return false
		}
		
		let stringRange = NSRange(location: 0, length: self.characters.count)
		let rangeOfFirstMatch = expression.rangeOfFirstMatch(in: self, options: [], range: stringRange)
		
		return rangeOfFirstMatch.location != NSNotFound
	}
	
	private func firstMatch(withRegEx regEx: NSRegularExpression) -> String? {
		
		let stringRange = NSRange(location: 0, length: self.characters.count)
		let rangeOfFirstMatch = regEx.rangeOfFirstMatch(in: self, options: [], range: stringRange)
		
		if rangeOfFirstMatch.location != NSNotFound {
			return (self as NSString).substring(with: rangeOfFirstMatch)
		}
		
		return nil
	}
	
}
