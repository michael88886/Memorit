//
//  MemoViewModel.swift
//  MemoIt
//
//  Created by mk mk on 10/6/19.
//  Copyright © 2019 MC2. All rights reserved.
//

import UIKit
import CoreData


class MemoViewModel {
	// MARK: - Properties
	// Memo list
	var memoList: [Memo]
	// Cache list
	var cacheList: NSCache<NSNumber, MemoModel>
	
	
	// Fetch result
	private var fetchResult: NSPersistentStoreAsynchronousResult? = nil
	var fetchingData: ((Bool) -> Void)?
	var isFetching: Bool = false
	
	
	// MARK: - Initialise
	init() {
		self.memoList = [Memo]()
		self.cacheList = NSCache<NSNumber, MemoModel>()
	}
	
	// MARK: - Public functions
	// Fetch data from database
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
	
	func updateCell() {
		
	}
	
}
