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
}
