//
//  HomeModelOperation.swift
//  MemoIt
//
//  Created by mk mk on 11/6/19.
//  Copyright © 2019 MC2. All rights reserved.
//

import Foundation
import CoreData

class HomeModelOperation: Operation {
	
	// MARK: - Properties
	// Completion handler
	var completion: ((MemoModel) -> Void)?
	
	// Memo object reference
	private let memo: Memo
	
	// MARK: - Init
	init (memo: Memo) {
		self.memo = memo
	}
	
	
	// MARK: - override functions
	override func main() {
		// Check cancel before start
		if isCancelled {
			return
		}
		
		let model: MemoModel
		let type = Helper.memoType(memo: memo)
		switch type {
		case .attach:
			model = AttachmentModel()
		case .todo:
			model = TodoModel
		case .voice:
			model = VoiceModel()
		}
		
	}
	
	
}
