//
//  UIHelper.swift
//  MemoIt
//
//  Created by mk mk on 6/6/19.
//  Copyright © 2019 MC2. All rights reserved.
//

import UIKit

class UIHelper {
	// Default height
	static let defaultH: CGFloat = 44
	
	// Default tint
	static let defaultTint: UIColor = #colorLiteral(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)
	
	// Separator
	static func separator(withColor: UIColor) -> UIView {
		let view = UIView()
		view.isUserInteractionEnabled = false
		view.backgroundColor = withColor
		return view		
	}
	
	// Label
	static func label(font: UIFont, textColor: UIColor?) -> UILabel {
		let label = UILabel()
		label.backgroundColor = .clear
		label.textColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)
		if let textColor = textColor {
			label.textColor = textColor
		}
		label.font = font
		label.numberOfLines = 1
		label.adjustsFontSizeToFitWidth = true
		label.minimumScaleFactor = 0.1
		return label
	}
	
	// Button
	static func button(icon: UIImage, tint: UIColor) -> UIButton {
		let btn = UIButton(type: .custom)
		btn.setImage(icon.withRenderingMode(.alwaysTemplate), for: .normal)
		btn.tintColor = tint
		return btn
	}
}
