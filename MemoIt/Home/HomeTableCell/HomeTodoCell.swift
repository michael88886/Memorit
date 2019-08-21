//
//  HomeTodoCell.swift
//  MemoIt
//
//  Created by mk mk on 11/6/19.
//  Copyright © 2019 MC2. All rights reserved.
//

import UIKit

class HomeTodoCell: HomeCell {
	
	// MARK: - Properties
	// - Constants
	// Preview list cell ID
	private let prevCellID = "PrevListCell"
	// Preview table row height
	private let prevRowH: CGFloat = 24
	// Unit font
	private let unitFont = UIFont.systemFont(ofSize: 12, weight: .light)
	// State font
	private let taskFont = UIFont.systemFont(ofSize: 34, weight: .regular)
	// Unit label width
	private let unitW: CGFloat = 44
	// Task label width
	private let taskW: CGFloat = 40
	// Text color
	private let labelColor: UIColor = #colorLiteral(red: 0.4756349325, green: 0.4756467342, blue: 0.4756404161, alpha: 1)
	
	// - Variables
	// Once flag
	private var once: Bool = true
	// Item list
	private var itemList = [(color: UIColor, title: String, isDone: Bool)]()
	
	
	// MARK: - Views
	// List table
	private lazy var listTable: UITableView = {
		let table = UITableView(frame: .zero, style: .plain)
		table.rowHeight = prevRowH
		table.separatorStyle = .none
		table.allowsMultipleSelection = false
		table.allowsSelection = false
		table.showsVerticalScrollIndicator = false
		table.isUserInteractionEnabled = false
		return table
	}() 
	
	// Total tasks label
	private lazy var totalLabel: UILabel = {
		let lb = UILabel()
		lb.font = taskFont
		lb.textAlignment = .right
		lb.textColor = labelColor
		return lb
	}()
	
	// MARK: - OVerride function
	override func prepareForReuse() {
		super.prepareForReuse()
		itemList.removeAll()
		listTable.reloadData()
	}
	
	override func feedCell(model: MemoModel) {
		super.feedCell(model: model)
		// Todo model
		guard let todoModel = model as? TodoModel else { return }
		itemList = todoModel.listItems
		listTable.reloadData()
		
		totalLabel.text = String(todoModel.totalTasks)
	}
}

// MARK: - UITableView data source / delegate
extension HomeTodoCell: UITableViewDataSource, UITableViewDelegate {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return itemList.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: prevCellID, for: indexPath)
		let data = itemList[indexPath.row]
		var sign = "•"
		if data.isDone == true { sign = "✓" }
		let itemStr = String(format: "%@ %@", sign, data.title)
		cell.textLabel?.text = itemStr
		cell.textLabel?.textColor = #colorLiteral(red: 0.6642242074, green: 0.6642400622, blue: 0.6642315388, alpha: 1)
		return cell
	}
}


// MARK: - Setup UI
extension HomeTodoCell {
	override func setup() {
		super.setup()
		
		// Totol unit label
		let totalUnitLabel = UILabel()
		totalUnitLabel.font = unitFont
		totalUnitLabel.text = "Task(s)"
		totalUnitLabel.textColor = labelColor
		contentView.addSubview(totalUnitLabel)
		totalUnitLabel.translatesAutoresizingMaskIntoConstraints = false
		totalUnitLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: Padding.p40).isActive = true
		totalUnitLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Padding.p20).isActive = true
		totalUnitLabel.widthAnchor.constraint(equalToConstant: unitW).isActive = true
		
		// Total label
		contentView.addSubview(totalLabel)
		totalLabel.translatesAutoresizingMaskIntoConstraints = false
		totalLabel.bottomAnchor.constraint(equalTo: totalUnitLabel.bottomAnchor, constant: Padding.p5).isActive = true
		totalLabel.trailingAnchor.constraint(equalTo: totalUnitLabel.leadingAnchor, constant: -Padding.p10).isActive = true
		totalLabel.widthAnchor.constraint(equalToConstant: taskW).isActive = true
		
		// List table
		listTable.dataSource = self
		listTable.delegate = self
		listTable.register(UITableViewCell.self, forCellReuseIdentifier: prevCellID)
		container.addSubview(listTable)
		listTable.translatesAutoresizingMaskIntoConstraints = false
		listTable.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: Padding.p5).isActive = true
		listTable.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: Padding.p10).isActive = true
		listTable.trailingAnchor.constraint(equalTo: totalLabel.leadingAnchor, constant: -Padding.p10).isActive = true
		listTable.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -Padding.p10).isActive = true
	}
}
