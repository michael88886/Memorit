//
//  ColorPickerCell.swift
//  MemoIt
//
//  Created by mk mk on 8/7/19.
//  Copyright © 2019 MC2. All rights reserved.
//

import UIKit

class ColorPickerCell: UICollectionViewCell {
    
	// MARK: - Views
	
	// Select container 
	private lazy var selectContainer: UIView = {
		let v = UIView()
		v.clipsToBounds = true
		v.backgroundColor = .white
		v.layer.borderColor = #colorLiteral(red: 0.6642242074, green: 0.6642400622, blue: 0.6642315388, alpha: 1).cgColor
		v.layer.borderWidth = 1.0
		return v
	}()
	
	// Selector
	private lazy var selector: UIImageView = {
		let imgV = UIImageView(image: #imageLiteral(resourceName: "MiniTick").withRenderingMode(.alwaysTemplate))
		imgV.tintColor = #colorLiteral(red: 0.5741485357, green: 0.5741624236, blue: 0.574154973, alpha: 1)
		return imgV
	}()
	
	
	// MARK: - Custom init
	override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setup()
	}
}

// MARK: - Override functions
extension ColorPickerCell {
	override func prepareForReuse() {
		selector.isHidden = true
		layer.borderColor = UIColor.clear.cgColor
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		selectContainer.layer.cornerRadius = selectContainer.frame.width / 2.0
	}
}

// MARK: - Public function
extension ColorPickerCell {
	
	// Select cell
	func select() {
		selector.isHidden = false
	}
	
	// Deselect cell
	func deselect() {
		selector.isHidden = true
	}
}

// MARK: - Setup UI
extension ColorPickerCell {
	private func setup() {
		layer.cornerRadius = 6
		
		// Selector container
		selectContainer.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(selectContainer)
		selectContainer.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -Padding.p5).isActive = true
		selectContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Padding.p5).isActive = true
		selectContainer.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.5).isActive = true
		selectContainer.widthAnchor.constraint(equalTo: selectContainer.heightAnchor).isActive = true
		
		// Selector
		selector.translatesAutoresizingMaskIntoConstraints = false
		selectContainer.addSubview(selector)
		selector.centerXAnchor.constraint(equalTo: selectContainer.centerXAnchor).isActive = true
		selector.centerYAnchor.constraint(equalTo: selectContainer.centerYAnchor).isActive = true
		selector.widthAnchor.constraint(equalTo: selectContainer.widthAnchor).isActive = true
		selector.heightAnchor.constraint(equalTo: selectContainer.heightAnchor).isActive = true
		selector.isHidden = true
		contentView.layoutIfNeeded()
	}
}
