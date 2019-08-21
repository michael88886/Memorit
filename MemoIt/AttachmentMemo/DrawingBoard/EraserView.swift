//
//  EraserView.swift
//  MemoIt
//
//  Created by mk mk on 20/8/19.
//  Copyright © 2019 MC2. All rights reserved.
//

import UIKit

class EraserView: UIView, DrawingTool {
	// MARK: - Views
	// Eraser
	private lazy var eraser: UIImageView = {
		let er = UIImageView(image: #imageLiteral(resourceName: "DrawEraserIdle"))
		er.contentMode = .scaleAspectFit
		return er
	}()
	
	// MARK: - Override init
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupUI()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError()
	}
}

// MARK: - Public function
extension EraserView {
	// Select
	func select() {
		eraser.image = #imageLiteral(resourceName: "DrawEraser")
	}
	
	// Deselect
	func deselect() {
		eraser.image = #imageLiteral(resourceName: "DrawEraserIdle")
	}
}

// MARK: - Setup UI
extension EraserView {
	private func setupUI() {
		// Eraser
		addSubview(eraser)
		eraser.translatesAutoresizingMaskIntoConstraints = false
		eraser.topAnchor.constraint(equalTo: topAnchor).isActive = true
		eraser.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
		eraser.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
		eraser.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
	}
}
