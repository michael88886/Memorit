//
//  UnfocusableTextField.swift
//  MemoIt
//
//  Created by mk mk on 10/7/19.
//  Copyright © 2019 MC2. All rights reserved.
//

import UIKit

class UnfocusableTextField: UITextField {
	// Hide cursor
	override func caretRect(for position: UITextPosition) -> CGRect {
		return .zero
	}
	
	// Disable menu
	override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
		return false
	}
}
