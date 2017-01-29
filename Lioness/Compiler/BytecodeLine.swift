//
//  BytecodeLine.swift
//  Lioness
//
//  Created by Louis D'hauwe on 11/12/2016.
//  Copyright © 2016 - 2017 Silver Fox. All rights reserved.
//

import Foundation

public protocol BytecodeLine: class, CustomStringConvertible {
	
	var encoded: String { get }
	
}

public typealias BytecodeBody = [BytecodeLine]
