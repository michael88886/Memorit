//
//  MemoViewModel.swift
//  MemoIt
//
//  Created by mk mk on 10/6/19.
//  Copyright © 2019 MC2. All rights reserved.
//

import UIKit
import CoreData

protocol HomeCellProtocol {
	func feedCell(model: MemoModel)
}

// MARK: - Memo type
@objc enum MemoType: Int {
	case attach
	case voice
	case todo
}

// MARK: - Memo view model
class MemoViewModel {
	// MARK: - Properties
	// - Constants
	let attachID = "AttachCell"
	let todoID = "TodoCell"
	let voiceID = "VoiceID"
	
	// Memo list
	var memoList = [Memo]()
	// Cache list
	var cacheList = NSCache<NSNumber, MemoModel>()
	
	
	// Fetch result
	private var fetchResult: NSPersistentStoreAsynchronousResult? = nil
	var fetchingData: ((Bool) -> Void)?
	var isFetching: Bool = false
	
	
	
	
	
	func updateCell(cell: UITableViewCell, indexpath: IndexPath) {
		let model = memoList[indexpath.row]
		let type = Helper.memoType(memo: model)
		switch type {
		case .attach:
			if let cell = cell as? HomeAttachCell {
				
			}
			
		case .todo:
			if let cell = cell as? HomeTodoCell {
				
			}
			
		case .voice:
			if let cell = cell as? HomeVoiceCell {
				
			}
		}
	}
	
	// Cell ID
	func cellId(atIndex: IndexPath) -> String {
		let model = memoList[atIndex.row]
		let type = Helper.memoType(memo: model)
		switch type {
		case .attach:
			return attachID
		case .todo:
			return todoID
		case .voice:
			return voiceID
		}
	}
	
}

// MARK: - Public functions
extension MemoViewModel {
	// MARK: - Fetch functions
	func fetchData() {
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
				print("end fetch")
				self.isFetching = false
				self.fetchingData?(false)
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
}
