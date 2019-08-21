//
//  PenView.swift
//  MemoIt
//
//  Created by mk mk on 20/8/19.
//  Copyright © 2019 MC2. All rights reserved.
//

import UIKit

protocol DrawingTool {
	func select()
	func deselect()
}

class PenView: UIView, DrawingTool {
	// MARK: - Views
	// Pen tip
	private lazy var penTip: UIImageView = {
		let tip = UIImageView(image: #imageLiteral(resourceName: "DrawTip").withRenderingMode(.alwaysTemplate))
		tip.tintColor = .black
		tip.contentMode = .scaleAspectFit
		return tip
	}()
	
	// Pen
	private lazy var pen: UIImageView = {
		let pv = UIImageView(image: #imageLiteral(resourceName: "DrawPenIdle"))
		pv.contentMode = .scaleAspectFit
		return pv
	}()
	
	
	// MARK: - Override init
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupUI()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

// MARK: - Public functions
extension PenView {
	// Update tip color
	func updateColor(color: UIColor) {
		self.penTip.tintColor = color
	}
	
	// Select
	func select() {
		pen.image = #imageLiteral(resourceName: "DrawPen")
	}
	
	// Deselect
	func deselect() {
		pen.image = #imageLiteral(resourceName: "DrawPenIdle")
	}
}


// MARK: - Setup UI
extension PenView {
	private func setupUI() {
		// Pen tip
		addSubview(penTip)
		penTip.translatesAutoresizingMaskIntoConstraints = false
		penTip.topAnchor.constraint(equalTo: topAnchor).isActive = true
		penTip.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
		penTip.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
		penTip.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
		
		// Pen
		addSubview(pen)
		pen.translatesAutoresizingMaskIntoConstraints = false
		pen.topAnchor.constraint(equalTo: topAnchor).isActive = true
		pen.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
		pen.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
		pen.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
	}
}
