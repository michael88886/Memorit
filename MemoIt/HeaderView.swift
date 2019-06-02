//
//  HeaderView.swift
//  MemoIt
//
//  Created by mk mk on 2/6/19.
//  Copyright © 2019 MC2. All rights reserved.
//

import UIKit

class HeaderView: UIView {

	// MARK: - Properties	
	
	// MARK: - Views
	private lazy var imageView: UIImageView = {
		let img = UIImageView()
		img.contentMode = .scaleAspectFill
		return img
	}()
	
	// - Canvas view
	private lazy var canvas: UIView = {
		let canv = UIView()
		canv.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.2)
		canv.isUserInteractionEnabled = false
		return canv
	}()
	
	// MARK: - Custom init
	override init(frame: CGRect) {
		super.init(frame: frame)
		loadView()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		loadView()
	}
}

// MARK: - Public functions
extension HeaderView {
	func updateImage(image: UIImage) {
		DispatchQueue.main.async {
			self.imageView.image = image
		}
	}
	
	func updateVertOffset(offset: CGFloat) {
		print("offset: \(offset)")
	}
}

// MARK: - Private functions
extension HeaderView {
	// Load view
	private func loadView() {
		
		clipsToBounds = true
		
		// Image view
		imageView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(imageView)
		imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
		imageView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
		imageView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
		imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
		
		imageView.image = #imageLiteral(resourceName: "BGwork")
		
		// Canvas
		canvas.translatesAutoresizingMaskIntoConstraints = false
		addSubview(canvas)
		canvas.topAnchor.constraint(equalTo: topAnchor).isActive = true
		canvas.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
		canvas.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
		canvas.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
	}
}

