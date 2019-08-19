//
//  ListViewModel.swift
//  MemoIt
//
//  Created by MICA17 on 3/7/19.
//  Copyright © 2019 MC2. All rights reserved.
//

import Foundation
import CoreData

struct ListItemModel {
    var title: String = ""
    var isDone: Bool = false
    var reminder: Date?
    var color: UIColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    
    init(title: String) {
        self.title = title
    }
}

class ListViewModel: NSObject {
    // MARK: Properties
	// - Constants
	// List cell id
	static let listCellID = "ListCell"
    // New cell height
	private let newCellH: CGFloat = 200
	// Cell height
	private let cellH: CGFloat = 44
	
    // - Variables
    // Task list
    private var taskList = [ListItemModel]()
	// Complete list
	private var completeList = [ListItemModel]()
	// List memo object reference
	private var memoData: ListMemo?
	// Is editing flag
	private var isEditing = false
	
    // - Closure
	// Reload table
    var reloadTable: (() -> Void)?
	// Reload cell
	var reloadCell: ((IndexPath) -> Void)?
	// List title
	var listTitle: ((String) -> Void)?
	
//    // Editing text view
//	var editingTextView: ((UITextView) -> Void)?	
	
}

// MARK: - Public function
extension ListViewModel {
	// MARK: - Core data functions
	// Check if should save data
	func save(title: String?) {
		if title != nil || taskList.count > 0 || isEditing {
			saveData(title)
		}
	}
	
	// Load data from core data
	func loadData(memo: ListMemo) {
		isEditing = true
		print("Load")
		
		// Title
		self.listTitle?(memo.title)
		// Load tasks
		if let tasks = memo.listItem, 
			tasks.count > 0 {
			for task in tasks {
				if let tsk = task as? ListItem {
					var itemModel = ListItemModel(title: tsk.title)
					itemModel.color = tsk.color
					itemModel.isDone = tsk.isDone
					itemModel.reminder = tsk.reminder as Date?
					taskList.append(itemModel)
				}
			}
		}
		// Refresh list
		self.reloadTable?()
		
		// Assign memo data
		self.memoData = memo			
	}
	
	
	// MARK: - Model functions
	// Add new task
	func addNewTask(_ task: ListItemModel) {
		taskList.append(task)
		self.reloadTable?()
	}
	
	// Remove task
	func removeTask(_ indexPath: IndexPath) {
		// Remove task
		taskList.remove(at: indexPath.row)
		// Refresh table
		self.reloadTable?()
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
    
	// If cell is able to perform [Done] action
	func hasComplete(indexpath : IndexPath) -> Bool {
		return taskList[indexpath.row].isDone
	}
	
	// MARK: - Table view funciton	
	// Number of items
	func numberOfItems() -> Int {
		return taskList.count
	}
	
	// Update cell
	func updateCell(_ tableView: UITableView, _ indexpath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: ListViewModel.listCellID, for: indexpath) as! ListTableCell
		let data = taskList[indexpath.row]
		cell.feedData(data: data)
		cell.updateCompletion = updateCompleteTask(_:_:)
		return cell
	}  	
	
	// Update complete task
	func updateCompleteTask(_ cell: ListTableCell, _ complete: Bool) {
		guard let indexpath = indexpathOfCell(cell: cell) else { return }
		taskList[indexpath.row].isDone = complete
		cell.setCompleteImage(complete: complete)
	}
}

// MARK: - Private function
extension ListViewModel {
	// Save data to core data
	private func saveData(_ title: String?) {
		print("Save")
		// Data context
		let context = Helper.dataContext()
		// List object
		var listObject: ListMemo!
		// Default title
		var titleName = "New list"
		// Color
		var color: UIColor?
		
		// Start core data
		context.perform {
			// List title
			if let listTitle = title, 
				listTitle.trimmingCharacters(in: .nonBaseCharacters) != "" {
				titleName = listTitle
			}
			
			if self.isEditing {
				// Editing
				let objId = (self.memoData?.objectID)!
				do {
					try listObject = context.existingObject(with: objId) as? ListMemo
					color = listObject.color
					listObject.listItem = nil	
				}
				catch {
					print("\(self) Failed to get object from ID")
				}
			}
			else {
				// New
				let entity = NSEntityDescription.entity(forEntityName: "ListMemo", in: context)!
				listObject = NSManagedObject(entity: entity, insertInto: context) as? ListMemo
			}
			
			// Title
			listObject.setValue(titleName, forKey: "title")
			// Modify time
			listObject.setValue(Date(), forKey: "timeModified")
			// Archived flag
			listObject.setValue(false, forKey: "archived")
			// Type
			listObject.setValue(MemoType.todo.rawValue, forKey: "type")
			// Color
			if color == nil { color = .white }
			listObject.setValue(color!, forKey: "color")
			
			// List item
			for item in self.taskList {
				let itemEntity = NSEntityDescription.entity(forEntityName: "ListItem", in: context)!
				let itemObj = NSManagedObject(entity: itemEntity, insertInto: context) as! ListItem
				
				// Item title
				itemObj.setValue(item.title, forKey: "title")
				// Item color
				itemObj.setValue(item.color, forKey: "color")
				// Item complete
				itemObj.setValue(item.isDone, forKey: "isDone")
				// Item reminder
				if let reminder = item.reminder {
					itemObj.setValue(reminder, forKey: "reminder")
				}
				listObject.addToListItem(itemObj)
			}
			
			// Save object
			do {
				try context.save()
			}
			catch {
				print("\(self): Failed to save data: ", error.localizedDescription)
				return
			}
			context.refreshAllObjects()
			
			// Send notification
			NotificationCenter.default.post(name: .reloadHomeList, object: nil)
		}
	}
	
	// Index of cell
	private func indexpathOfCell(cell: UITableViewCell) -> IndexPath? {
		guard let superview = cell.superview as? UITableView else { return nil }
		return superview.indexPath(for: cell)
	}
}

// MARK: - Closure function
extension ListViewModel {
	// Update task title
	private func updateTaskTitle(_ cell: UITableViewCell, _ text: String) {
		guard let indexpath = indexpathOfCell(cell: cell) else { return }
		// Update title
		taskList[indexpath.row].title = text
		// Reload cell
		self.reloadCell?(indexpath)
	}
	
	// Task complete
	private func taskComplete(_ cell: UITableViewCell, completed: Bool) {
		guard let indexpath = indexpathOfCell(cell: cell) else { return }
		// Update complete state
		taskList[indexpath.row].isDone = completed
	}
}
