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
	
	// - Closure
	var brushSize: ((CGFloat) -> Void)?
	
	
	// MARK: - Custom init
	init (size: CGFloat) {
		super.init(frame: .zero)
		setupUI(size: size)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError()
	}
}

// MARK: - Public funtion
extension BrushSizeButton {
	// Select
	func select() {
		layer.borderColor = UIColor.white.cgColor
	}
	
	// Deselect
	func deselect() {
		layer.borderColor = UIColor.clear.cgColor
	}
}

// MARK: - Setup UI
extension BrushSizeButton {
	private func setupUI(size: CGFloat) {
		// Border width
		layer.borderWidth = 2.0
		
		
		// Demo size view
		let demoView = UIView()
		demoView.backgroundColor = .black
		demoView.isUserInteractionEnabled = false
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
		demoLabel.text = String(format: "%.1f", size)
		demoLabel.adjustsFontSizeToFitWidth = true
		addSubview(demoLabel)
		demoLabel.translatesAutoresizingMaskIntoConstraints = false
		demoLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
		demoLabel.topAnchor.constraint(equalTo: centerYAnchor, constant: Padding.p5).isActive = true
	}
}
