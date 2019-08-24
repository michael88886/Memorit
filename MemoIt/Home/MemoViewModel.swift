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
	let searchID = "SearchID"
	
	// - Variables
	// Memo list
	private var memoList = [Memo]()
	// Cache list
//	private var cacheList = NSCache<NSNumber, MemoModel>()
	// Loading opearation queue
	private let loadingQueue = OperationQueue()
	// Loading operations
	private var loadingOperations: [IndexPath: LoadMemoOperation] = [:] 
	// Search list
	private(set) var searchList = [Memo]()
	// Is fetching flag
	private(set) var isFetching: Bool = false
	// Fetch result
	private var fetchResult: NSPersistentStoreAsynchronousResult? = nil
	
	// - Closures
	// Reload table closure
	var reloadData: (() -> Void)?
	// Data has been fetched
	var fetchingData: ((Bool) -> Void)?
	// Edit memo
	var editMemo: ((Memo) -> Void)?
	
}

// MARK: - Public functions
extension MemoViewModel {
	// MARK: - Fetch functions
	@objc func fetchData() {
        // Clear data
		self.memoList.removeAll()
        
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
	
	func sortData() {
		memoList.sort { (memo, memo1) -> Bool in
			if let date1 = memo.timeModified as Date?, 
				let date2 = memo1.timeModified as Date? {
				return date1.compare(date2) == .orderedDescending
			}
			return false
		}
	}
	
	// Get data from indexpath
	func dataFromIndex(indexpath: IndexPath) -> Memo {
		return memoList[indexpath.row]
	}
	
	// Edit memo
	func editMemoAt(_ indexpath: IndexPath) {
		let data = memoList[indexpath.row]
		self.editMemo?(data)
	}
	
	// Select memo from search list
	func editFromSearch(_ indexpath: IndexPath) {
		// Data from search list
		let data = searchList[indexpath.row]
		// Data indexpath in memo list
		var indexpath: IndexPath? = nil
		// Get indexpath for memo list
		for (index, d) in memoList.enumerated() {
			if d == data {
				indexpath = IndexPath(item: index, section: 0)
				break
			}
		}
		
		guard let idpa = indexpath else { return }
		editMemoAt(idpa)
	}
	
	// Add memo to memo list
	func addMemoToList(memo: Memo) {
		memoList.insert(memo, at: 0)
	}
	
	// Delete memo
	func deleteMemo(_ atIndexpath: IndexPath) {
		// Get data from memo list
		let data = memoList[atIndexpath.row]
		// - Update entity from core data
		// Get context
		let context = Helper.dataContext()
		// Update entity & save
		context.perform {
			let objID = data.objectID
			do {
				let memoObj = try context.existingObject(with: objID) as? Memo
				memoObj?.archived = true
				try context.save()
			}
			catch {
				print("Failed to delete object from core data: \(error.localizedDescription)")
			}
		}
		
		// Remove from memo list
		memoList.remove(at: atIndexpath.row)
		// Reload table
		self.reloadData?()
	}
	
	// Number of items
	func numberOfItems() -> Int {
		return memoList.count
	}
	
	
	// MARK: - Search function
	// Reset search result
	func resetSearchResult() {
		searchList.removeAll()
	}
	
	// If can perform search
	func canSearch() -> Bool {
		return !memoList.isEmpty
	}
	
	// Search memo
	func searchMemo(text: String) {
		for memo in memoList {
			stringMatchResult(text, memo)
		}
	}
	
	// Number of search result
	func numberOfSearchResult() -> Int {
		return searchList.count
	}
	
	// Update search cell
	func updateSearchCell(_ tableView: UITableView, _ indexpath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: searchID, for: indexpath) as! SearchViewCell
		let data = searchList[indexpath.row]
		cell.updateCell(memo: data)
		return cell
	}
}

// MARK: - Tableview function
extension MemoViewModel {
	// MARK: - Feed table cell functions
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
			let newOP = LoadMemoOperation(memo: memoList[indexpath.row])
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

// MARK: - Private function
extension MemoViewModel {
	// String match for search result
	private func stringMatchResult(_ pattern: String, _ memo: Memo) {
		var matched = false
		
		// Match title
		if let title = memo.title {
			matched = containsMatch(of: pattern, inString: title)
		}
		
		
		if matched {
			// Title matched, add to search list
			searchList.append(memo)
			return
		}
		else {
			// Title not matched, search body
			let type: MemoType = MemoType(rawValue: memo.type.rawValue)!
			switch type {
			case .attach:
				searchAttahcmentMemo(pattern, memo)
				
			case .todo:
				searchListMemo(pattern, memo)
				
			default:
				()
			}
		}
	}
	
	// Contain match
	private func containsMatch(of pattern: String, inString string: String) -> Bool {
		guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
			return false
		}
		let range = NSRange(string.startIndex..., in: string)
		return regex.firstMatch(in: string, options: [], range: range) != nil
	}
	
	// Search Attachment memo
	private func searchAttahcmentMemo(_ pattern: String, _ memo: Memo) {
		guard let attMemo = memo as? AttachmentMemo else { return }
		if let body = attMemo.attributedString?.string {
			if containsMatch(of: pattern, inString: body) {
				searchList.append(attMemo)
			}
		}
		else {
			// FIXME: Match label
		}
	}
	
	// Search list
	private func searchListMemo(_ pattern: String, _ memo: Memo) {
		guard let listMemo = memo as? ListMemo else { return }
		if let listItems = listMemo.listItem, listItems.count > 0 {
			for item in listItems {
				if let itm = item as? ListItem, 
					containsMatch(of: pattern, inString: itm.title) {
					searchList.append(memo)
				}
			}
		}
	}
}
