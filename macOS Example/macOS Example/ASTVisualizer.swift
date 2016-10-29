//
//  ASTVisualizer.swift
//  macOS Example
//
//  Created by Louis D'hauwe on 26/10/2016.
//  Copyright © 2016 Silver Fox. All rights reserved.
//

import Foundation
import CoreGraphics
import Lioness
import AppKit

fileprivate let minNodeHeight: CGFloat = 50
fileprivate let minNodeWidth: CGFloat = 80

fileprivate let minNodeLevelSpacing: CGFloat = 30
fileprivate let minNodeXSpacing: CGFloat = 20

fileprivate extension ASTNode {
	
	var drawSize: CGSize {
		
		let width: CGFloat = CGFloat(widestNumberOfChildNodes) * minNodeWidth + minNodeXSpacing * CGFloat(widestNumberOfChildNodes)
		
		let totalNumberOfNodesDeep = CGFloat(deephestNumberOfChildNodes) + 1
		let heightSpacing = minNodeLevelSpacing * (totalNumberOfNodesDeep + 1)
		let height = totalNumberOfNodesDeep * minNodeHeight + heightSpacing
		
		return CGSize(width: width, height: height)
		
	}
	
	
	// make lazy?
	var deephestNumberOfChildNodes: Int {
		
		if childNodes.isEmpty {
			return 0
		}
		
		var deephest = 1

		for (_, node) in childNodes {
			
			let d = 1 + node.deephestNumberOfChildNodes
			
			if d > deephest {
				deephest = d
			}
			
		}
		
		return deephest
		
	}
	
	// make lazy?
	var widestNumberOfChildNodes: Int {
		
		if childNodes.isEmpty {
			return 1
		}
		
		var wide = 0
		
		for (_, node) in childNodes {
			
			wide += node.widestNumberOfChildNodes
			
		}
		
		return wide
		
	}
	
}

class ASTVisualizer {
	
	fileprivate let body: BodyNode

	init(body: BodyNode) {
		
		self.body = body

		print("w: \(body.widestNumberOfChildNodes)")
		print("h: \(body.deephestNumberOfChildNodes)")
		
	}
	
	lazy fileprivate var canvasSize: CGSize = {

		return self.body.drawSize
		
	}()
	
	func draw() -> NSImage? {
		
		let size = canvasSize
		
		print(size)

		return draw(withSize: size)

	}
	
	fileprivate func draw(withSize size: CGSize) -> NSImage {

		let composedImage = NSImage(size: size)
		
		composedImage.lockFocus()
		let ctx = NSGraphicsContext.current()
		ctx?.imageInterpolation = .high
		ctx?.shouldAntialias = true
		
		
		let rect1 = CGRect(x: 0, y: 0, width: size.width, height: size.height)
		
		let path = NSBezierPath(rect: normalizedRect(rect1))
		
		NSColor.white.setFill()
		path.fill()
		
		
		
		let startX = size.width/2.0
		
		drawNode(body, atPosition: CGPoint(x: startX, y: minNodeLevelSpacing), atYLevel: 1, withAvailableWidth: size.width)

		composedImage.unlockFocus()
		
		return composedImage
	}
	
	fileprivate func normalizedRect(_ r: CGRect) -> CGRect {
		
		// invert y for macOS
		let invertedY = canvasSize.height - (r.origin.y + r.height)
		return CGRect(x: r.origin.x, y: invertedY, width: r.width, height: r.height)
	}
	
	fileprivate func normalizedPoint(_ r: CGPoint) -> CGPoint {
		
		// invert y for macOS
		let invertedY = canvasSize.height - (r.y)
		return CGPoint(x: r.x, y: invertedY)
	}
	
	
	// Don't need to pass availableWidth? (can just be childNode.drawSize.width?)
	fileprivate func drawNode(_ node: ASTNode, atPosition point: CGPoint, atYLevel yLevel: CGFloat, withAvailableWidth availableWidth: CGFloat, withParentRect parentRect: CGRect? = nil) {
		
		let x: CGFloat = point.x - minNodeWidth/2.0
		let y: CGFloat = point.y
		
		let rect = CGRect(x: x, y: y, width: minNodeWidth, height: minNodeHeight)
				
		let path = NSBezierPath(roundedRect: normalizedRect(rect), xRadius: 12.0, yRadius: 12.0)
		
		NSColor.blue.withAlphaComponent(0.2).setFill()

		path.fill()
		
		NSColor.blue.withAlphaComponent(0.4).setStroke()
		path.lineWidth = 2.0
		path.stroke()
		
		
		if let parentRect = parentRect {
			
			let linePath = NSBezierPath()
			let pointA = CGPoint(x: parentRect.origin.x + parentRect.size.width / 2.0, y: parentRect.origin.y + parentRect.size.height)
			linePath.move(to: normalizedPoint(pointA))
			
			let pointB = CGPoint(x: rect.origin.x + rect.size.width / 2.0, y: rect.origin.y)

			linePath.line(to: normalizedPoint(pointB))
			
			NSColor.blue.withAlphaComponent(0.4).setStroke()
			linePath.lineWidth = 2.0
			linePath.stroke()
		}
		
		
		if let text = node.nodeDescription {
		
			let attr = NSAttributedString(string: text)
			
			let size = attr.size()
			
			var textRect = rect
			// TODO: max 0
			textRect.origin.x += (rect.width - size.width) / 2.0
			textRect.origin.y += (rect.height - size.height) / 2.0
			
			attr.draw(in: normalizedRect(textRect))
		
		}
		
		
		var i: CGFloat = 0

		for (_, childNode) in node.childNodes {
			
			let newAvailableWidth = childNode.drawSize.width
			
			let farX = point.x - (availableWidth) / 2.0
			
			var newXPosition = farX
			
			for j in 0..<Int(i+1) {
				
				let jWidth = node.childNodes[j].1.drawSize.width
				if CGFloat(j) == i {
					newXPosition += jWidth / 2.0
				} else {
					newXPosition += jWidth

				}
			}
			
			
			let newYPosition = point.y + minNodeHeight + minNodeLevelSpacing

			let newYLevel = yLevel + 1
			
			let childPosition = CGPoint(x: newXPosition, y: newYPosition)
			
			drawNode(childNode, atPosition: childPosition, atYLevel: newYLevel, withAvailableWidth: newAvailableWidth, withParentRect: rect)
			
			i += 1
		}
		
	}
	
}
