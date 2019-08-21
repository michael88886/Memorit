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
	private let selector_W: CGFloat = 0.4
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
		selectorView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
		selectorView.isUserInteractionEnabled = false
		selectorView.layer.cornerRadius = selectorH / 2.0
		selectorView.layer.shadowColor = UIColor.black.cgColor
		selectorView.layer.shadowOpacity = 0.2
		selectorView.layer.shadowRadius = 2
		selectorView.layer.shadowOffset = CGSize(width: 0, height: 1)
		selectorView.isHidden = true
		addSubview(selectorView)
		selectorView.translatesAutoresizingMaskIntoConstraints = false
		selectorView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
		selectorView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
		selectorView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: selector_W).isActive = true
		selectorView.heightAnchor.constraint(equalToConstant: selectorH).isActive = true
	}
}
