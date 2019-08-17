//
//  MemoViewModel.swift
//  MemoIt
//
//  Created by mk mk on 10/6/19.
//  Copyright © 2019 MC2. All rights reserved.
//

import UIKit
import CoreData

// MARK: - Memo type
@objc public enum MemoType: Int32 {
	case attach = 0
	case voice = 1
	case todo = 2
}

// MARK: - Memo view model
class MemoViewModel: NSObject {
	// MARK: - Properties
	// - Constants
	let attachID = "AttachCell"
	let todoID = "TodoCell"
	let voiceID = "VoiceCell"
	
	// Memo list
	var memoList = [Memo]()
	// Cache list
	var cacheList = NSCache<NSNumber, MemoModel>()
	// Loading opearation queue
	private let loadingQueue = OperationQueue()
	// Loading operations
	private var loadingOperations: [IndexPath: LoadMemoOperation] = [:] 
	
	// Fetch result
	private var fetchResult: NSPersistentStoreAsynchronousResult? = nil
	
	// Reload table closure
	var reloadData: (() -> Void)?
	
	var fetchingData: ((Bool) -> Void)?
	// Is fetching flag
	var isFetching: Bool = false
	
}

// MARK: - Public functions
extension MemoViewModel {
	// MARK: - Fetch functions
	@objc func fetchData() {
        // Clear cache
        cacheList.removeAllObjects()
        
		// Data context
		let context = Helper.dataContext()
		// Fetch request
		let fetchRequest = NSFetchRequest<Memo>(entityName: "Memo")
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timeModified", ascending: false)]
		fetchRequest.predicate = NSPredicate(format: "archived == %@", NSNumber(value: false))
		
		// Astnchronous fetch
		let asyncFetchRequest = NSAsynchronousFetchRequest(fetchRequest: fetchRequest) { (asychronousFetchResult) in
			guard let result = asychronousFetchResult.finalResult else { return }
			// Call back main queue
			DispatchQueue.main.async {
				// Assign data
				self.memoList = result
				print("end fetch: \(self.memoList.count)")
				self.isFetching = false
				self.fetchingData?(false)
				self.reloadData?()
			}
		}
		
		// Execte feteching
		do {
			self.isFetching = true
			self.fetchingData?(true)
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
	
	// Get data from indexpath
	func dataFromIndex(indexpath: IndexPath) -> Memo {
		return memoList[indexpath.row]
	}
	
	// Reload item at indexpath
	func refreshData(_ atIndexpath: IndexPath) {
		// Remove data from cache list
		self.cacheList.removeObject(forKey: NSNumber(integerLiteral: atIndexpath.row))
	}
}

// MARK: - Tableview function
extension MemoViewModel {
	// MARK: - Feed table cell functions
	func updateCell(_ tableview: UITableView, _ indexpath: IndexPath) -> UITableViewCell {
		// Get correct cell
		let cell = cellById(tableview, indexpath)
		
		if let model = cacheList.object(forKey: NSNumber(integerLiteral: indexpath.row)) {
			print("in cache")
			// Data avaliable, feed cell
			self.feedCell(cell, model: model)			
		}
		else {
			print("Not in cache")
			// Completion closure
			let completionClosure: (MemoModel) -> () = { [weak self] model in
				guard let self = self else { return }
				print("UPdate")
				self.feedCell(cell, model: model)
				// Add loaded data to cache
				self.cacheList.setObject(model, forKey: NSNumber(integerLiteral: indexpath.row))
				// Remove operation
				self.loadingOperations.removeValue(forKey: indexpath)
			}
			
			// Check existing opeation
			if let operation = loadingOperations[indexpath] {
				// Found opearation
				if let dataModel = operation.memoModel {
					// Data loaded
					feedCell(cell, model: dataModel)
					// Add loaded data to cache
					self.cacheList.setObject(dataModel, forKey: NSNumber(integerLiteral: indexpath.row))
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
				let newOP = LoadMemoOperation(memo: memoList[indexpath.row])
				// Assgin completion hander
				newOP.completion = completionClosure
				// Add to operation queue
				loadingQueue.addOperation(newOP)
				// Set reference
				loadingOperations[indexpath] = newOP
			}
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
		let model = memoList[index.row]
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
			let newOp = LoadMemoOperation(memo: memoList[indexpath.row])
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
