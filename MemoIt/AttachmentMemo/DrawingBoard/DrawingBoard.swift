//
//  DrawingBoard.swift
//  MemoIt
//
//  Created by mk mk on 20/8/19.
//  Copyright © 2019 MC2. All rights reserved.
//

import UIKit

// MARK: - Drawing tool
enum Brush {
	case pen
	case eraser
}

final class DrawingBoard: UIImageView {
	// MARK: - Properties
	// - Constants
	// Eraser size
	private let eraserSize: CGFloat = 4.0
	
	// - Variables
	// Brush mode
	private var brush: CGBlendMode = .normal
	// Line width
	private var lineWidth: CGFloat = 0
	// Final width
	private var finalWidth: CGFloat = 0
	// Stroke color
	private var strokeColor: CGColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).cgColor
	// Swiped flag
	private var swiped: Bool = false
	// Last point
	private var lastPoint: CGPoint = .zero
	// Image array
	private var images = [UIImage]()
	// Cache images array
	private var cacheImage = [UIImage]()
	// Final image
	private var finalImage: UIImage?
	
	// - Closures
	// Drawing image empty
	var drawingImageEmpty: ((Bool) -> Void)?
	// Drawing cache empty
	var drawingCacheEmpty: ((Bool) -> Void)?
	// Save drawing
	var saveDrawing: ((UIImage) -> Void)?
}

// MARK: - Override function
extension DrawingBoard {
	// Touch begin
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		swiped = false
		if let touch = touches.first {
			lastPoint = touch.location(in: self)
			finalWidth = lineWidth
			if brush == .clear {
				finalWidth *= eraserSize
			}
		}
	}
	
	// Touch moved
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		swiped = true
		if let touch = touches.first {
			let currentPoint = touch.location(in: self)
			drawLine(fromPoint: lastPoint, toPoint: currentPoint)
			lastPoint = currentPoint
		}
	}
	
	// Touch ended
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		if !swiped {
			drawLine(fromPoint: lastPoint, toPoint: lastPoint)
		}
		
		UIGraphicsBeginImageContext(frame.size)
		backgroundColor?.setFill()
		UIRectFill(CGRect(origin: CGPoint.zero, size: frame.size))
		self.image?.draw(in: CGRect(origin: CGPoint.zero, size: frame.size), blendMode: .normal, alpha: 1.0)
		finalImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		images.append(finalImage!)
		if cacheImage.count > 0 {
			cacheImage.removeAll()
		}
		self.image = images.last
		finalImage = nil
		validateButton()
	}
}

// MARK: - Public functions
extension DrawingBoard {
	// MARK: - Drawing functions
	// Set drawing tool
	func drawBrush(brush: Brush) {
		switch brush {
		case .pen:
			self.brush = .normal
		case .eraser:
			self.brush = .clear
		}
	}
	
	// Set line width
	func drawWidth(wdith: CGFloat) {
		lineWidth = wdith
	}
	
	// Set draw color
	func drawColor(color: UIColor) {
		strokeColor = color.cgColor
	}
	
	
	// MARK: - Control function
	// Is empty drawing?
	func isEmpty() -> Bool {
		return images.isEmpty
	}
	
	// Clear all
	func clearAllDraw() {
		print("sss")
		self.image = nil
		images.removeAll()
		cacheImage.removeAll()
		validateButton()
	}
	
	// Undo
	func undoDraw() {
		guard images.count > 0 else { return }
		let lastImg = images.last
		images.removeLast()
		self.image = images.last
		cacheImage.append(lastImg!)
		validateButton()
	}
	
	// Redo
	func redoDraw() {
		guard cacheImage.count > 0 else { return }
		let lastImg = cacheImage.last
		cacheImage.removeLast()
		images.append(lastImg!)
		self.image = images.last
		validateButton()
	}
	
	// Save drawing
	func saveDraw() {
		guard let image = self.image else { return }
		self.saveDrawing?(image)
	}
}

// MARK: - Private functions
extension DrawingBoard {
	// Draw line
	private func drawLine(fromPoint: CGPoint, toPoint: CGPoint) {
		UIGraphicsBeginImageContext(frame.size)
		guard let context = UIGraphicsGetCurrentContext() else { return }
		self.image?.draw(in: CGRect(origin: CGPoint.zero, size: frame.size))
		
		context.move(to: fromPoint)
		context.addLine(to: toPoint)
		
		context.setLineCap(.round)
		context.setLineWidth(finalWidth)
		context.setStrokeColor(strokeColor)
		context.setBlendMode(brush)
		
		context.strokePath()
		context.drawPath(using: .stroke)
		
		self.image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
	}
	
	// Valiadate control buttons
	private func validateButton() {
		print("validate button")
		// If images array empty
		self.drawingImageEmpty?(images.count > 0)
		// If cache image array empty
		self.drawingCacheEmpty?(cacheImage.count > 0)
	}
}

