//
//  BrushSizeView.swift
//  MemoIt
//
//  Created by mk mk on 21/8/19.
//  Copyright © 2019 MC2. All rights reserved.
//

import UIKit

class BrushSizeButton: UIControl {
	
	// MARK: - Properties
	// - Constants
	// Demo view width multiplier
	private let demo_W: CGFloat = 0.6
	// Selector width multiplier
	private let selector_W: CGFloat = 0.3
	// Selector height
	private let selectorH: CGFloat = 4
	
	// - Variable
	private var size: CGFloat = 0
	
	// - Closure
	var brushSize: ((CGFloat) -> Void)?
	
	
	// MARK: - select indicator
	private lazy var selectorView = UIView()
	
	// MARK: - Custom init
	init (brushSize: CGFloat) {
		super.init(frame: .zero)
		self.size = brushSize
		setupUI()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError()
	}
}

// MARK: - Public funtion
extension BrushSizeButton {
	// Select
	func select() {
		selectorView.isHidden = false
		self.brushSize?(self.size)
	}
	
	// Deselect
	func deselect() {
		selectorView.isHidden = true
	}
}

// MARK: - Setup UI
extension BrushSizeButton {
	private func setupUI() {
		
		// Demo size view
		let demoView = UIView()
		demoView.backgroundColor = .black
		demoView.layer.cornerRadius = 4.0
		addSubview(demoView)
		demoView.translatesAutoresizingMaskIntoConstraints = false
		demoView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
		demoView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: demo_W).isActive = true
		demoView.bottomAnchor.constraint(equalTo: centerYAnchor).isActive = true
		demoView.heightAnchor.constraint(equalToConstant: size).isActive = true
		
		// Demo label
		let demoLabel = UILabel()
		demoLabel.textAlignment = .center
		demoLabel.font = UIFont.systemFont(ofSize: 10)
		demoLabel.text = String(format: "%.1f", self.size)
		demoLabel.adjustsFontSizeToFitWidth = true
		addSubview(demoLabel)
		demoLabel.translatesAutoresizingMaskIntoConstraints = false
		demoLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
		demoLabel.topAnchor.constraint(equalTo: centerYAnchor, constant: Padding.p2).isActive = true
		
		// Selector view
		selectorView.backgroundColor = #colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 0.5)
		selectorView.isUserInteractionEnabled = false
		selectorView.layer.cornerRadius = 8.0
		selectorView.isHidden = true
		addSubview(selectorView)
		selectorView.translatesAutoresizingMaskIntoConstraints = false
		selectorView.topAnchor.constraint(equalTo: topAnchor, constant: Padding.p5).isActive = true
		selectorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Padding.p5).isActive = true
		selectorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Padding.p5).isActive = true
		selectorView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Padding.p5).isActive = true
	}
}
