//
//  LoadPreviewAttachmentOpeartion.swift
//  MemoIt
//
//  Created by mk mk on 16/6/19.
//  Copyright © 2019 MC2. All rights reserved.
//

import Foundation

class LoadPreviewAttachmentOperation: Operation {
	
	// MARK: - Properties
	// - Attachment model
	var attachmentModel: AttachmentModel?
	// - Compeletion handler
	var loadingCompeletHandler: ((AttachmentModel) -> Void)?
	
	// - Model reference
	// Data reference
	private let memoAttachment: MemoAttachment
	// Cell reference
	private let thumbnailSize: CGSize
	// Thumbnail quality
	private let quality: CGFloat = 0.25
	
	// MARK: - Init
	init(thumbnailSize: CGSize, memoAttachment: MemoAttachment) {
		self.thumbnailSize = thumbnailSize
		self.memoAttachment = memoAttachment
	}
	
	// MARK: - Override function
	override func main() {
		
		// Check cancel before start
		if isCancelled { return }
		
		switch self.memoAttachment.type {
		case .image:
			processImageAttachment()
		case .audio:
			processVoiceAttachment()
		}
	}
}

extension LoadPreviewAttachmentOperation {
	private func processImageAttachment() {
		let img = UIImage(contentsOfFile: self.memoAttachment.url.path) ?? #imageLiteral(resourceName: "Pin44")
		let cover = Helper.imageThumbnail(image: img, targetSize: self.thumbnailSize, quality: self.quality)
		self.attachmentModel = AttachmentModel(image: cover!)
		
		// Check cancel
		if isCancelled { return }
		
		// Complete
		if let completed = loadingCompeletHandler {
			guard let attModel = attachmentModel else { return }
			DispatchQueue.main.async {
				completed(attModel)
			}
		}
	}
	
	private func processVoiceAttachment() {
		let cover = Helper.imageThumbnail(image: #imageLiteral(resourceName: "SoundWave44"), targetSize: self.thumbnailSize, quality: self.quality)
		let duaStr = Helper.mediaDuration(url: self.memoAttachment.url)
		self.attachmentModel = VoiceAttachmentModel(image: cover!, duration: duaStr)
		
		// Check cancel
		if isCancelled { return }
		
		// Complete
		if let completed = loadingCompeletHandler {
			guard let attModel = attachmentModel else { return }
			DispatchQueue.main.async {
				completed(attModel)
			}
		}
	}
}
