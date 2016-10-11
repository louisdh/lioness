//
//  Regex.swift
//  Lioness
//
//  Created by Louis D'hauwe on 04/10/2016.
//  Copyright © 2016 Silver Fox. All rights reserved.
//

import Foundation

//var expressions = [String : NSRegularExpression]()

public extension String {
	
    public func match(_ regex: String) -> String? {

//        if let exists = expressions[regex] {
//            expression = exists
//        } else {
//            expression = try! NSRegularExpression(pattern: "^\(regex)", options: [])
//            expressions[regex] = expression
//        }
		
		guard let expression = try? NSRegularExpression(pattern: "^\(regex)", options: []) else {
			return nil
		}
		
		return match(withRegEx: expression)
    }
	
	public func match(withRegEx regEx: NSRegularExpression) -> String? {
		
		let stringRange = NSRange(location: 0, length: self.characters.count)
		let rangeOfFirstMatch = regEx.rangeOfFirstMatch(in: self, options: [], range: stringRange)
		
		if rangeOfFirstMatch.location != NSNotFound {
			return (self as NSString).substring(with: rangeOfFirstMatch)
		}
		
		return nil
	}
	
}
