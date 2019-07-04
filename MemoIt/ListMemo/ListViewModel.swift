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

class ListViewModel {
    
    
    // MARK: Properties
    
    
    // - Variables
    // Task list
    private var taskList = [ListItemModel]()
    // New list item model reference
    private var newTask: ListItemModel?
    
    
    // - Closure
    var reloadTable: (() -> Void)?
    
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
}

// MARK: - Private function
extension ListViewModel {
    
}
