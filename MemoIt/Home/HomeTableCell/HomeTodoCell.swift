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
	private let prevRowH: CGFloat = 28
	// Progress font size
	private let pgFontSize: CGFloat = 20
	//
	
	// - Variables
	// Once flag
	private var once: Bool = true
	// Item list
	private var itemList = [(color: UIColor, title: String)]()
	
	// MARK: - Views
	// Progress container
	private lazy var progressView: MKCircleProgress = {
		let pv = MKCircleProgress()
		pv.trackColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1).withAlphaComponent(0.3)
		pv.textSize = 20
		return pv
	}()
	
	// List table
	private lazy var listTable: UITableView = {
		let table = UITableView(frame: .zero, style: .plain)
		table.rowHeight = prevRowH
		table.separatorStyle = .none
		table.allowsMultipleSelection = false
		table.allowsSelection = false
		table.showsVerticalScrollIndicator = false
		table.isUserInteractionEnabled = false
		table.dataSource = self
		table.delegate = self
		table.register(UITableViewCell.self, forCellReuseIdentifier: prevCellID)
		return table
	}() 
	
	
	
	// MARK: - OVerride function
	override func prepareForReuse() {
		super.prepareForReuse()
		progressView.resetProgress()
		itemList.removeAll()
		listTable.reloadData()
	}
	
	override func feedCell(model: MemoModel) {
		super.feedCell(model: model)
		print("Feed todo cell:  \(model)")
		// Todo model
		guard let todoModel = model as? TodoModel else { return }
		itemList = todoModel.listItems
		progressView.setProgress(value: todoModel.percent)
//		listTable.reloadData()
//		progressView.setProgress(value: 0.6)
//		progressView.animationProgress(progress: todoModel.percent)
	}
	
}


// MARK: - Cell UI
extension HomeTodoCell {
	override func setup() {
		super.setup()
		
		// Progress view
		progressView.translatesAutoresizingMaskIntoConstraints = false
		container.addSubview(progressView)		
		progressView.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: Padding.p10).isActive = true
		progressView.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -Padding.p20).isActive = true
		progressView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -Padding.p10).isActive = true
		progressView.widthAnchor.constraint(equalTo: progressView.heightAnchor).isActive = true
		
		// List table
		listTable.translatesAutoresizingMaskIntoConstraints = false
		container.addSubview(listTable)
		listTable.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: Padding.p10).isActive = true
		listTable.leftAnchor.constraint(equalTo: container.leftAnchor, constant: Padding.p20).isActive = true
		listTable.rightAnchor.constraint(equalTo: progressView.leftAnchor, constant: -Padding.p20).isActive = true
		listTable.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -Padding.p10).isActive = true
	}
}


// UITableView data source / delegate
extension HomeTodoCell: UITableViewDataSource, UITableViewDelegate {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return itemList.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: prevCellID, for: indexPath)
		let data = itemList[indexPath.row]
		let itemStr = String(format: "• %@", data.title)
		cell.textLabel?.text = itemStr
		cell.textLabel?.textColor = #colorLiteral(red: 0.6642242074, green: 0.6642400622, blue: 0.6642315388, alpha: 1)
		return cell
	}
}
