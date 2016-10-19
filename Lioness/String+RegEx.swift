//
//  Regex.swift
//  Lioness
//
//  Created by Louis D'hauwe on 04/10/2016.
//  Copyright © 2016 Silver Fox. All rights reserved.
//

import Foundation

//var expressions = [String : NSRegularExpression]()

extension String {
	
	func firstMatch(withRegExPattern pattern: String) -> String? {

//        if let exists = expressions[regex] {
//            expression = exists
//        } else {
//            expression = try! NSRegularExpression(pattern: "^\(regex)", options: [])
//            expressions[regex] = expression
//        }
		
		guard let expression = try? NSRegularExpression(pattern: "^\(pattern)", options: []) else {
			return nil
		}
		
		return firstMatch(withRegEx: expression)
    }
	
	fileprivate func firstMatch(withRegEx regEx: NSRegularExpression) -> String? {
		
		let stringRange = NSRange(location: 0, length: self.characters.count)
		let rangeOfFirstMatch = regEx.rangeOfFirstMatch(in: self, options: [], range: stringRange)
		
		if rangeOfFirstMatch.location != NSNotFound {
			return (self as NSString).substring(with: rangeOfFirstMatch)
		}
		
		return nil
	}
	
}
