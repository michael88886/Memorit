//
//  UIHelper.swift
//  MemoIt
//
//  Created by mk mk on 6/6/19.
//  Copyright © 2019 MC2. All rights reserved.
//

import UIKit

class UIHelper {
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
}
