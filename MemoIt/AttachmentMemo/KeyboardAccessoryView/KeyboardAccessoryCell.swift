//
//  KeyboardAccessoryCell.swift
//  MemoIt
//
//  Created by mk mk on 18/8/19.
//  Copyright © 2019 MC2. All rights reserved.
//

import UIKit

final class KeyboardAccessoryCell: ImageCell {
	// MARK: - Properties
	// - Views
	// Selected bar (Bottom bar)
	private lazy var selectedBar = UIHelper.separator(withColor: .clear)
	
	// - Variables
	// Select color
	var selectColor: UIColor = .clear
	
	// Override tint color
	override var tintColor: UIColor! {
		didSet {
			selectedBar.backgroundColor = tintColor
		}
	}
	
	// MARK: - Override UI
	override func setupUI() {
		super.setupUI()
		
		// Selected bar 
		contentView.addSubview(selectedBar)
		selectedBar.translatesAutoresizingMaskIntoConstraints = false
		selectedBar.heightAnchor.constraint(equalToConstant: 2).isActive = true
		selectedBar.topAnchor.constraint(equalTo: imageView.bottomAnchor).isActive = true
		selectedBar.widthAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 0.5).isActive = true
		selectedBar.centerXAnchor.constraint(equalTo: imageView.centerXAnchor).isActive = true
	}
}

// MARK: - Override function
extension KeyboardAccessoryCell {
	override func prepareForReuse() {
		selectedBar.backgroundColor = .clear
	}
}

// MARK: - Public function
extension KeyboardAccessoryCell {
	func selectCell() {
		imageView.tintColor = selectColor
		selectedBar.backgroundColor = selectColor
	}
}
