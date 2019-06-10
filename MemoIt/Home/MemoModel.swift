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
	var title: String
	// Date modified
	var dateStr: Date
	// Memo color
	var color: UIColor
	// Memo label
	var label: String?
	
	// Initialise
	init() {
		self.title = String()
		self.dateStr = Date()
		self.color = .clear
		label = nil
	}
}
