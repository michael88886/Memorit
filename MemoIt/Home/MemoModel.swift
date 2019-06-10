//
//  MemoModel.swift
//  MemoIt
//
//  Created by mk mk on 8/6/19.
//  Copyright © 2019 MC2. All rights reserved.
//

import UIKit

// MARK: - Memo protocol
protocol MemoProtocol {
	// Memo title
	var title: String { get }
	// Date string
	var dateStr: String { get }
	// Memo color
	var color: UIColor { get }
	// Memo label
	var label: String { get } 
}


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
