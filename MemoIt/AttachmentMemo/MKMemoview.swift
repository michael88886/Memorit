//
//  MKMemoview.swift
//  MemoIt
//
//  Created by mk mk on 18/8/19.
//  Copyright © 2019 MC2. All rights reserved.
//

import UIKit

class MKMemoview: UITextView {
	// MARK: - Properties
	// - Constants
	// Default text color
	private let fontColor = #colorLiteral(red: 0.370555222, green: 0.3705646992, blue: 0.3705595732, alpha: 1)
	// Default font size
	private let fontSize: CGFloat = 18
	// Text highlight color
	private let textHighlightColor = #colorLiteral(red: 0.9995340705, green: 0.988355577, blue: 0.4726552367, alpha: 0.6)
	
	// MARK: - Override init
	override init(frame: CGRect, textContainer: NSTextContainer?) {
		super.init(frame: frame, textContainer: textContainer)
		setup()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setup()
	}
}

// MARK: - Setup
extension MKMemoview {
	private func setup() {
		// Default setting
		isEditable = true
		isScrollEnabled = false
		bounces = true
		showsHorizontalScrollIndicator = false
		showsVerticalScrollIndicator = false
		textContainer.lineFragmentPadding = 0
		adjustsFontForContentSizeCategory = true
		allowsEditingTextAttributes = true
		
		let para = NSMutableParagraphStyle()
		para.lineSpacing = 10.0
		
		// Text view background color
		backgroundColor = .clear
		
		tintColor = #colorLiteral(red: 1, green: 0.8039215686, blue: 0, alpha: 1)
		
		// Set default attribute
		typingAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize),
							NSAttributedString.Key.foregroundColor: fontColor,
							NSAttributedString.Key.paragraphStyle: para]
		self.textStorage.addAttributes(typingAttributes, range: NSRange(location: 0, length: self.textStorage.length))
	}
}


// MARK: - Public function
extension MKMemoview {
	// Set bold text
	func boldtext(isBold: Bool) {
		if isBold {
			typingAttributes[.font] = applyTrait(trait: .traitBold)
		}
		else {
			typingAttributes[.font] = removeTrait(trait: .traitBold)
		}
		applyToSelecteText(attribute: typingAttributes)
	}
	
	// Set italic text
	func italicText(isItalic: Bool) {
		if isItalic {
			typingAttributes[.font] = applyTrait(trait: .traitItalic)
		}
		else {
			typingAttributes[.font] = removeTrait(trait: .traitItalic)
		}
		applyToSelecteText(attribute: typingAttributes)
	}
	
	// Set underline text
	func underlineText(isUnderline: Bool) {
		if isUnderline {
			typingAttributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
		}
		else {
			typingAttributes[.underlineStyle] = 0
		}
		applyToSelecteText(attribute: typingAttributes)   
	}
	
	// Set strike through text
	func strikeThroughText(isStrikeThrough: Bool) {
		if isStrikeThrough {
			typingAttributes[.strikethroughStyle] = NSUnderlineStyle.single.rawValue
		}
		else {
			typingAttributes[.strikethroughStyle] = 0
		}
		applyToSelecteText(attribute: typingAttributes)
	}
}

// MARK; - Private funciton
extension MKMemoview {
	// Apply trait
	private func applyTrait(trait: UIFontDescriptor.SymbolicTraits) -> UIFont {
		let font = typingAttributes[NSAttributedString.Key.font] as! UIFont
		var symbolicTrait = font.fontDescriptor.symbolicTraits
		if !symbolicTrait.contains(trait) {
			symbolicTrait.insert(trait)
		}
		return createFont(trait: symbolicTrait)
	}
	
	// Remove trait
	private func removeTrait(trait: UIFontDescriptor.SymbolicTraits) -> UIFont {
		let font = typingAttributes[NSAttributedString.Key.font] as! UIFont
		var symbolicTrait = font.fontDescriptor.symbolicTraits
		if symbolicTrait.contains(trait) {
			symbolicTrait.remove(trait)
		}
		return createFont(trait: symbolicTrait)
	}
	
	// Create new font from symbolic trait
	private func createFont(trait: UIFontDescriptor.SymbolicTraits) -> UIFont {
		// Font descriptor
		let descriptor = UIFontDescriptor().withSymbolicTraits(trait)!
		return UIFont(descriptor: descriptor, size: fontSize)
	}
	
	// Apply attribute to selected text
	private func applyToSelecteText(attribute: [NSAttributedString.Key: Any]) {
		// If selected text range is avaliable
		if let selectedTextRange = self.selectedTextRange {
			// If text is selected, calculate range and convert to NSRange
			if !selectedTextRange.isEmpty {
				// Calculate range
				let location = offset(from: beginningOfDocument, to: selectedTextRange.start)
				let length = offset(from: selectedTextRange.start, to: selectedTextRange.end)
				let range = NSRange(location: location, length: length)
				// Apply new attribute to text storage
				self.textStorage.beginEditing()
				self.textStorage.addAttributes(attribute, range: range)
				self.textStorage.endEditing()
			}
		}
	}
}
