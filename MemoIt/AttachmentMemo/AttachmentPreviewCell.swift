//
//  AttachmentPreviewCell.swift
//  MemoIt
//
//  Created by mk mk on 19/8/19.
//  Copyright © 2019 MC2. All rights reserved.
//

import UIKit

final class AttachmentPreviewCell: ImageCell {
	// MARK: - Properties
	// Image border color
	private let borderColor: UIColor = #colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1)
	// Corner radius
	private let cornerRadius: CGFloat = 8.0
	
	// Select cell flag
	private(set) var isCellSelected: Bool = false
	
	
	// MARK: - Views
	// Time label
	private lazy var timeLabel: UILabel = {
		let label = UILabel()
		label.text = "00:00:00"
		label.textAlignment = .right
		label.textColor = #colorLiteral(red: 0.4756349325, green: 0.4756467342, blue: 0.4756404161, alpha: 1)
		label.font = UIFont.monospacedDigitSystemFont(ofSize: 12, weight: .regular)
		return label
	}()
	
	// Selected layer
	private var selectLayer: CAShapeLayer?
	
	
	// MARK: - Override UI
	override func setupUI() {
		super.setupUI()
		// Image view
		imageView.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
		imageView.contentMode = .scaleAspectFit
		imageView.clipsToBounds = true
		imageView.image = #imageLiteral(resourceName: "Pin")
		imageView.layer.cornerRadius = cornerRadius
		imageView.layer.borderWidth = 1
		imageView.layer.borderColor = borderColor.cgColor
		
		// Time label
		timeLabel.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(timeLabel)
		timeLabel.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -Padding.p5).isActive = true
		timeLabel.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -Padding.p5).isActive = true
		timeLabel.isHidden = true
	}	
}

// MARK: - Override functions
extension AttachmentPreviewCell {
	override func prepareForReuse() {
		super.prepareForReuse()
		imageView.image = #imageLiteral(resourceName: "Attach44")
		imageView.backgroundColor = .clear
		imageView.layer.borderColor = borderColor.cgColor
		timeLabel.text = ""
		timeLabel.isHidden = true
	}
}

// MARK: - Public function
extension AttachmentPreviewCell {
	// Update cell
	func UpdateCell(model: AttachmentModel) {
		// Set image
		self.imageView.image = model.coverImage
		
		// Duration string, if avaliable
        if model.type == .audio {
            self.timeLabel.text = model.duration
            self.timeLabel.isHidden = false
            self.imageView.backgroundColor = UIColor.white
        }
        else {
            self.imageView.layer.borderColor = UIColor.clear.cgColor
        }
	}
	
	// Select cell
	func selectCell() {
        isCellSelected = true
        // Select cell
        self.selectLayer = createSelectLayer(frame: contentView.frame)
        layer.addSublayer(self.selectLayer!)
	}
    
    // Deselect Cell
    func deselectCell() {
        isCellSelected = false
        // Deselect cell
        guard let selectLayer = self.selectLayer else { return }
        selectLayer.removeFromSuperlayer()
        self.selectLayer = nil
    }

}

// MARK: - Private funciton
extension AttachmentPreviewCell {
	private func createSelectLayer(frame: CGRect) -> CAShapeLayer {
		let layer = CAShapeLayer()
		layer.path = UIBezierPath(roundedRect: frame, cornerRadius: cornerRadius).cgPath
		layer.fillColor = #colorLiteral(red: 1, green: 0.8823529412, blue: 0.4, alpha: 0.3).cgColor
		layer.lineWidth = 6.0
		layer.strokeColor = #colorLiteral(red: 1, green: 0.8823529412, blue: 0.4, alpha: 1).cgColor
		return layer
	}
}

