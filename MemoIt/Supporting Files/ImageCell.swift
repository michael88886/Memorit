//
//  ImageCell.swift
//  MemoIt
//
//  Created by mk mk on 18/8/19.
//  Copyright © 2019 MC2. All rights reserved.
//

import UIKit

class ImageCell: UICollectionViewCell {
	// MARK: - Views
	// - Image view
	lazy var imageView: UIImageView = UIImageView()
	
	// MARK: - OVeride init
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupUI()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		fatalError()
	}
	
	// NARK: - Setup UI
	func setupUI() {
		// Image view
		imageView.contentMode = .scaleAspectFit
		
		// Image view
		contentView.addSubview(imageView)
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Padding.p5).isActive = true
		imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Padding.p5).isActive = true
		imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Padding.p5).isActive = true
		imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Padding.p5).isActive = true
	}
}

// MARK: - Override function
extension ImageCell {
	override func prepareForReuse() {
		super.prepareForReuse()
		imageView.image = nil
		imageView.backgroundColor = UIColor.clear
	}
}
