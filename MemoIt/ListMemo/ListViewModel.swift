//
//  ListViewModel.swift
//  MemoIt
//
//  Created by MICA17 on 3/7/19.
//  Copyright © 2019 MC2. All rights reserved.
//

import Foundation


private struct ListItemModel {
    var title: String = ""
    var isDone: Bool = false
    var reminder: Date?
    var color: UIColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    var isNew: Bool = false
    
    init(title: String) {
        self.title = title
    }
    
    static func newCell() -> ListItemModel {
        var item = ListItemModel(title: "")
        item.isNew = true
        return item
    }
}

class ListViewModel: NSObject {
    
    
    // MARK: Properties
	// - Constants
	// New cell id
	static let newCellID = "ListNewCell"
	// List cell id
    static let listCellID = "ListCell"
    // New cell height
	private let newCellH: CGFloat = 200
	// Cell height
	private let cellH: CGFloat = 44
	
    // - Variables
    // Task list
    private var taskList = [ListItemModel]()
    // New list item model reference
    private var newTask: ListItemModel?
    
	
    
    // - Closure
	// Reload table
    var reloadTable: (() -> Void)?
    // Editing text view
	var editingTextView: ((UITextView) -> Void)?
	
}

// MARK: - Public function
extension ListViewModel {
    // Number of items
    func numberOfItems() -> Int {
        return taskList.count
    }
    
    // Load task for list object
    func loadTask(list: ListMemo) {
        guard let itemlist = list.listItem,
            itemlist.count > 0 else { return }
        // Load tasks into list
        for task in itemlist {
            if let obj = task as? ListItem {
                // Create list item model
                var taskModel = ListItemModel(title: obj.title)
                taskModel.color = obj.color
                taskModel.isDone = obj.isDone
                taskModel.reminder = obj.reminder as Date?
                // Add to list
                taskList.insert(taskModel, at: 0)
            }
        }
    }
    
    // Add new task
    func addNewTask() {
        // Create [new] model
        self.newTask = ListItemModel.newCell()
        // Add to list
        taskList.append(self.newTask!)
        
        
        print("items: \(taskList.count)")
        // Refresh table
        self.reloadTable?()
    }
	
	// Update cell
	func updateCell(_ tableview: UITableView, _ indexpath: IndexPath) -> UITableViewCell{
		// Get correct cell
		let cell = cellByType(tableview, indexpath)
		let model = taskList[indexpath.row]
		
		if model.isNew {
			// New
			let cell = cell as! ListAddCell
			self.editingTextView?(cell.titleTextView)
		}
		else {
			// Normal
			
		}
		
		
		return cell
	}
	
	// Cell height
	func cellHeight(_ indexpath: IndexPath) -> CGFloat {
		let model = taskList[indexpath.row]
		if model.isNew {
			return newCellH
		}
		return cellH
	}
}

// MARK: - Private function
extension ListViewModel {
    // Cell by type
	private func cellByType(_ tableview: UITableView, _ indexpath: IndexPath) -> UITableViewCell {
		
		let model = taskList[indexpath.row]
		if model.isNew {
			// New cell
			return tableview.dequeueReusableCell(withIdentifier: ListViewModel.newCellID, for: indexpath) as! ListAddCell
		}
		else {
			// List cellr
			return tableview.dequeueReusableCell(withIdentifier: ListViewModel.listCellID, for: indexpath) as! ListTableCell
		}
		
	}
}
