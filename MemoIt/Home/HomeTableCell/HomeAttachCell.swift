//
//  HomeTableCell.swift
//  MemoIt
//
//  Created by mk mk on 7/6/19.
//  Copyright © 2019 MC2. All rights reserved.
//

import UIKit

class HomeAttachCell: HomeCell {
	// MARK: - Properties
	// - Variables
	// Preview width constraint
	private var prevImgWCst = NSLayoutConstraint()
	
	// MARK: - Views
	// Text view
	private lazy var textView: UITextView = {
		let txv = UITextView()
		txv.isUserInteractionEnabled = false
		txv.textContainer.lineBreakMode = .byClipping
		txv.textContainer.maximumNumberOfLines = 3
		return txv
	}()
	
	// Preview image view
	private lazy var prevImageView = UIImageView()
	
    
	// MARK: - Override fucntions
	override func prepareForReuse() {
		super.prepareForReuse()
		textView.text = ""
		
		// Reset preview image width constraint
		if prevImageView.isHidden == false {
			prevImgWCst.constant = 0
			prevImageView.isHidden = false
			prevImageView.image = nil
			contentView.layoutIfNeeded()
		}
	}
	
	override func feedCell(model: MemoModel) {
		super.feedCell(model: model)
		// Attach model
		guard let attachModel = model as? AttachModel else { return }
		
		// Text
		textView.attributedText = attachModel.prevText
		applyAttribute()
		textView.scrollRangeToVisible(NSRange(location: 0, length: 0))
		
		// Preview image
		if attachModel.haveAttachment {
			// Update preview image width
			prevImgWCst.constant = prevImageView.bounds.height
			prevImageView.isHidden = false
			prevImageView.image = attachModel.prevImage
			contentView.layoutIfNeeded()
		}
	}
}

// MARK: - Private function
extension HomeAttachCell {
	func applyAttribute() {
		// Paragraph style
		let para = NSMutableParagraphStyle()
		para.lineSpacing = 4.0
		
		// Attributes
		let attribute = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14), 
						 NSAttributedString.Key.foregroundColor : #colorLiteral(red: 0.4756349325, green: 0.4756467342, blue: 0.4756404161, alpha: 1), 
						 NSAttributedString.Key.paragraphStyle : para]
		// Apply attribut
		textView.textStorage.addAttributes(attribute, 
										   range: NSRange(location: 0, length: textView.textStorage.length))
	}
}

// MARK: - Setup UI
extension HomeAttachCell {
	override func setup() {
		super.setup()
		
		// Preview image
		prevImageView.clipsToBounds = true
		prevImageView.isHidden = true
		prevImageView.layer.cornerRadius = 8.0
		container.addSubview(prevImageView)
		prevImageView.translatesAutoresizingMaskIntoConstraints = false
		prevImageView.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: Padding.p10).isActive = true
		prevImageView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -Padding.p10).isActive = true
		prevImageView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -Padding.p10).isActive = true
		prevImgWCst = prevImageView.widthAnchor.constraint(equalToConstant: 0)
		prevImgWCst.isActive = true
		
		// Text view
		container.addSubview(textView)
		textView.translatesAutoresizingMaskIntoConstraints = false
		textView.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: Padding.p5).isActive = true
		textView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: Padding.p20).isActive = true
		textView.trailingAnchor.constraint(equalTo: prevImageView.leadingAnchor, constant: -Padding.p10).isActive = true
		textView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -Padding.p10).isActive = true
	}
}
