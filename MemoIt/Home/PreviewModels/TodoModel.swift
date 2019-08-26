//
//  TodoModel.swift
//  MemoIt
//
//  Created by mk mk on 10/6/19.
//  Copyright © 2019 MC2. All rights reserved.
//

import UIKit

class TodoModel: MemoModel {
	// MARK: - Properties
	// Maximum items
	let maxItem: Int = 3
	
	// Total tasks
	var totalTasks: Int = 0
	
	// Preview list items
	lazy var listItems = [(color: UIColor, title: String, isDone: Bool)]()
	
	// MARK: - Custom init
	init(memo: ListMemo) {
		super.init(memo: memo)
		self.type = MemoType.todo
	}
}
