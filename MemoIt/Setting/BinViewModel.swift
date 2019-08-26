//
//  BinViewModel.swift
//  MemoIt
//
//  Created by mk mk on 26/8/19.
//  Copyright © 2019 MC2. All rights reserved.
//

import UIKit
import CoreData

class BinViewModel: NSObject {
	
	// MARK: - Properties
	// - Constants
	let attachID = "AttachCell"
	let todoID = "TodoCell"
	let voiceID = "VoiceCell"
	let searchID = "SearchID"
	
	// - Variables
	// Bin list 
	private var binList = [Memo]()
	// Loading opearation queue
	private let loadingQueue = OperationQueue()
	// Loading operations
	private var loadingOperations: [IndexPath: LoadMemoOperation] = [:]
	// Fetch result
	private var fetchResult: NSPersistentStoreAsynchronousResult? = nil
	
	// - Closures
	// Reload table closure
	var reloadData: (() -> Void)?
}

// MARK: - Public function
extension BinViewModel {
	// MARK: - Fetch function
	func fetchData() {
		// Clear list
		self.binList.removeAll()
		
		// Data context
		let context = Helper.dataContext()
		// Fetch request
		let fetchRequest = NSFetchRequest<Memo>(entityName: "Memo")
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timeModified", ascending: false)]
		fetchRequest.predicate = NSPredicate(format: "archived == %@", NSNumber(value: true))
		
		// Asynchronous fetch
		let asyncFetchRequest = NSAsynchronousFetchRequest(fetchRequest: fetchRequest) { (asychronousFetchResult) in
			guard let result = asychronousFetchResult.finalResult else { return }
			// Call back main queue
			DispatchQueue.main.async {
				// Assign data
				self.binList = result
				self.reloadData?()
			}
		}
		
		// Execute feteching
		do {
			fetchResult = try context.execute(asyncFetchRequest) as? NSPersistentStoreAsynchronousResult
		}
		catch {
			print("[\(self): Failed to fetch data]")
		}
	}
	
	// Cancel fetch data
	func cancelFetch() {
		fetchResult?.cancel()
	}
	
	// Delete data
	func deleteData(_ indexpath: IndexPath) {
		// Get data from list
		let data = binList[indexpath.row]
		// Remove from list
		binList.remove(at: indexpath.row)
		// - Update database
		// Context
		let context = Helper.dataContext()
		// Update and save
		context.perform {
			let objID = data.objectID
			do {
				let memoObj = try context.existingObject(with: objID) as? Memo
				if let memoObj = memoObj {
					context.delete(memoObj)
					try context.save()
				}	
			}
			catch {
				print("Failed to Remove object from core data: \(error.localizedDescription)")
			}
		}
		// Reload table
		self.reloadData?()
	}
	
	// Restore data
	func restoreData(_ indexpath: IndexPath) {
		// Get data from list
		let data = binList[indexpath.row]
		// Remove from list
		binList.remove(at: indexpath.row)
		// - Update database
		// Context
		let context = Helper.dataContext()
		// Update and save
		context.perform {
			let objID = data.objectID
			do {
				let memoObj = try context.existingObject(with: objID) as? Memo
				memoObj?.archived = false
				try context.save()
			}
			catch {
				print("Failed to restore object from core data: \(error.localizedDescription)")
			}
		}
		
		// Reload table
		self.reloadData?()
	}
}

// MARK: - Tableview function
extension BinViewModel {
	// Number of items
	func numberOfItems() -> Int {
		return binList.count
	}
	
	// MARK: Setup cell
	func updateCell(_ tableview: UITableView, _ indexpath: IndexPath) -> UITableViewCell {
		// Get correct cell
		let cell = cellById(tableview, indexpath)
		
		// Completion closure
		let completionClosure: (MemoModel) -> () = { [weak self] model in
			guard let self = self else { return }
			self.feedCell(cell, model: model)
			// Remove operation
			self.loadingOperations.removeValue(forKey: indexpath)
		}
		
		// Check existing opeation
		if let operation = loadingOperations[indexpath] {
			// Found opearation
			if let dataModel = operation.memoModel {
				// Data loaded
				feedCell(cell, model: dataModel)
				// Remove operation
				self.loadingOperations.removeValue(forKey: indexpath)
			}
			else {
				// Data not loaded
				operation.completion = completionClosure
			}
		}
		else {
			// No opearion yet, create new op
			let newOP = LoadMemoOperation(memo: binList[indexpath.row])
			// Assgin completion hander
			newOP.completion = completionClosure
			// Add to operation queue
			loadingQueue.addOperation(newOP)
			// Set reference
			loadingOperations[indexpath] = newOP
		}
		return cell
	}
	
	// Feed data to cell
	func feedCell(_ cell: UITableViewCell, model: MemoModel) {
		let type: MemoType = MemoType(rawValue: model.type!.rawValue)!
		switch type {
		case .attach:
			guard let cell = cell as? HomeAttachCell,
				let model = model as? AttachModel else { return }
			cell.feedCell(model: model)
			
		case .todo:
			guard let cell = cell as? HomeTodoCell,
				let model = model as? TodoModel else { return }
			cell.feedCell(model: model)
			
		case .voice:
			guard let cell = cell as? HomeVoiceCell,
				let model = model as? VoiceModel else { return }
			cell.feedCell(model: model)
		}			
	}
	
	// Cell ID
	func cellById(_ tableview: UITableView, _ index: IndexPath) -> HomeCell {
		let model = binList[index.row]
		let type: MemoType = model.type
		switch type {
		case .attach:
			return tableview.dequeueReusableCell(withIdentifier: attachID, for: index) as! HomeAttachCell
		case .todo:
			return tableview.dequeueReusableCell(withIdentifier: todoID, for: index) as! HomeTodoCell
		case .voice:
			return tableview.dequeueReusableCell(withIdentifier: voiceID, for: index) as! HomeVoiceCell
		}
	}
	
	// MARK: - Prefetch function
	// Prefetch data
	func prefetchData(_ indexPaths: [IndexPath]) {
		// Search for existing operation
		for indexpath in indexPaths {
			// Found exising operation loading for current cell, skip
			if let _ = loadingOperations[indexpath] {
				continue
			}
			
			// Create new operation for cell
			let newOp = LoadMemoOperation(memo: binList[indexpath.row])
			loadingQueue.addOperation(newOp)
			loadingOperations[indexpath] = newOp
		}
	}
	
	// Cancel prefetch
	func cancelPrefetch(_ indexPaths: [IndexPath]) {
		for indexpath in indexPaths {
			if let operation = loadingOperations[indexpath] {
				operation.cancel()
				loadingOperations.removeValue(forKey: indexpath)
			}
		}
	}
}
