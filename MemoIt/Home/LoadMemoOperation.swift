//
//  HomeModelOperation.swift
//  MemoIt
//
//  Created by mk mk on 11/6/19.
//  Copyright © 2019 MC2. All rights reserved.
//

import Foundation
import CoreData

class LoadMemoOperation: Operation {
	// MARK: - Properties
	// Thumbnail size
	private let imageSize: CGFloat = 80
	
	// Memo model
	var memoModel: MemoModel?
	
	// Completion handler
	var completion: ((MemoModel) -> Void)?
	
	// Memo object reference
	let memo: Memo
	
	// MARK: - Init
	init (memo: Memo) {
		self.memo = memo
	}
	
	override func main() {
		// Check if cancel before start
		if isCancelled { return }
		// Processing
		let type: MemoType = MemoType(rawValue: self.memo.type.rawValue)!
		switch type {
		case .attach:
			guard let memo = self.memo as? AttachmentMemo else { return }
			attachOperation(memo: memo)
			
		case .todo:
			guard let memo = self.memo as? ListMemo else { return }
			todoOperation(memo: memo)
			
		case .voice:
			guard let memo = self.memo as? VoiceMemo else { return }
			voiceOperation(memo: memo)
		}
	}
}

// MARK: - Processing operation
extension LoadMemoOperation {
	// Processing attachment model
	private func attachOperation(memo: AttachmentMemo) {
		self.memoModel = AttachModel(memo: memo)
		guard let model = self.memoModel as? AttachModel else { return }
		if let attach = memo.attachments, 
			attach.count > 0 {
			model.haveAttachment = true
			// Thumbnail size
			let size = CGSize(width: imageSize, height: imageSize)
			// Default preview image
			model.prevImage = Helper.imageThumbnail(image: #imageLiteral(resourceName: "Pin44"), targetSize: size, quality: 0.25)
			// Search preview image
			for att in attach {
				guard let attr = att as? Attachment else { return }
				// Found image type attachment
				if attr.attachType == AttachmentType.image.id {
					// Image directory
					let memoDir = Helper.memoDirectory().appendingPathComponent(memo.memoID)
					// Image URL
					let imgURL = memoDir.appendingPathComponent(attr.attachID)
					if let img = UIImage(contentsOfFile: imgURL.path) {
					// Set found preview image
					model.prevImage = Helper.imageThumbnail(image: img, targetSize: size, quality: 0.25)
					}
				}
			}
		}
		
		// Check for cancel
		if isCancelled { return }
		
		// Completion
		if let complete = completion {
			DispatchQueue.main.async {
				complete(model)
			} 
		}
	} 
	
	// Processing todo model
	private func todoOperation(memo: ListMemo) {
		self.memoModel = TodoModel(memo: memo)
		guard let model = self.memoModel as? TodoModel else { return }
		if let items = memo.listItem, 
			items.count > 0 {
			// Finished item
			var cmptItem: Int = 0
			for item in items {
				guard let listItm = item as? ListItem else { return }
				if model.listItems.count < model.maxItem {
					let itm: (color: UIColor, title: String) = (listItm.color, listItm.title)
					model.listItems.append(itm)
				}
				
				// Get all completed item
				if listItm.isDone == true {
					cmptItem += 1
				}
			}
			
			
			print("cmp: \(cmptItem)")
			model.percent = CGFloat(cmptItem / items.count)
		}
		
		// Completion
		if let complete = completion {
			DispatchQueue.main.async {
				complete(model)
			}
		}
	}
	
	// Processing voice model
	private func voiceOperation(memo: VoiceMemo) {
		self.memoModel = VoiceModel(memo: memo)
		guard let model = self.memoModel as? VoiceModel else { return }
		model.audioURL = Helper.audioDirectory().appendingPathComponent(memo.memoID)
		
		// Check for cancel
		if isCancelled { return }
		
		// Completion
		if let complete = completion {
			DispatchQueue.main.async {
				complete(model)
			}
		}
	}
}
