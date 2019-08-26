//
//  MemoModel.swift
//  MemoIt
//
//  Created by mk mk on 8/6/19.
//  Copyright © 2019 MC2. All rights reserved.
//

import UIKit

class MemoModel {
	// MARK: - Properties
	// Memo title
	var title: String = ""
	// Date modified
	var date: Date
	// Memo color
	var color: UIColor
	// Memo label
	var label: String?
	// Memo type
	var type: MemoType!
	
	// Initialise
	init(memo: Memo) {
		if let title = memo.title {
			self.title = title
		} 
		 
		self.date = memo.timeModified as Date
		self.color = memo.color
		self.label = memo.label?.name
	}
}
