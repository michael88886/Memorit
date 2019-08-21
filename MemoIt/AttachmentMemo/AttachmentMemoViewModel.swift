//
//  MemoAttachmentModel.swift
//  MemoIt
//
//  Created by MICA17 on 19/8/19.
//  Copyright © 2019 MC2. All rights reserved.
//

import UIKit

// MARK: - MemoAttachmentViewModel
class AttachmentMemoViewModel: NSObject {
    
    // MARK: - Properties
    // - Constants
    // Preview cell id
    static let previewCellId = "PreviewCell"
    
    // - Variables
	// Memo title
	private(set) var memoTitle: String = ""
	// Memo attributeText
	
    // Attachment list
    private var attachmentList = [AttachmentModel]()
    // Cache list
    private var cacheList = NSCache<NSNumber, AttachmentModel>()
    // Loading opearation queue
    private let loadingQueue = OperationQueue()
    // Loading operations
    private var loadingOperations: [IndexPath: LoadAttachmentOperation] = [:]
    // Editing indexpath
    private var editingIndexes = [IndexPath]()
    // Deleting attachment
    private var deletingAttachments = [AttachmentModel]()
    
    // - Closure
    // Reload collection view
    var reloadCollection: (() -> Void)?
	// Reload cell at indexpath
	var reloadCellAtIndexpath: ((IndexPath) -> Void)?
    // Update badge button
    var updateBadgeCount: ((Int) -> Void)?
	// No more attachment
	var noMoreAttachment: (() -> Void)?
}


// MARK: - Public functions
extension AttachmentMemoViewModel {
	// MARK: - Save load function
	func saveMemo() {
		// Data context
		let context = Helper.dataContext()
		
		
		
	}
	
	func loadMemo(memo: AttachmentMemo) {
		
	}
	
    // MARK: - Attachment editing functions
    // Add attachment
    func addAttachment(_ attachment: AttachmentModel) {
        attachmentList.append(attachment)
        self.reloadCollection?()
    }
    
    // Clear editing attachment
    func clearEditingAttachment(_ collectionView: UICollectionView) {
        for indexpath in editingIndexes {
            if let cell = collectionView.cellForItem(at: indexpath) as? AttachmentPreviewCell {
                if cell.isCellSelected {
                    // Deselect all cell
                    cell.deselectCell()
                }
            }
        }
        // Clear editing indexpath
        editingIndexes.removeAll()
    }
    
    // Delete attachments
    func deleteAttachments() {
        for indexpath in editingIndexes {
            // Get attachment
            let attachment = attachmentList[indexpath.row]
            // Add to deleting list
            deletingAttachments.append(attachment)
			// Remove from cache list
			cacheList.removeObject(forKey: NSNumber(integerLiteral: indexpath.row))
            // Remove from attachment list
            attachmentList = attachmentList.filter { $0.filename != attachment.filename }
        }
		
		if attachmentList.isEmpty {
			self.noMoreAttachment?()
		}
    }
    
    // Add editing index
    func addEditingIndex(_ collectionView: UICollectionView, _ indexpath: IndexPath) {
        // Add editing index
        editingIndexes.append(indexpath)
        
        // Selecting cell for editing
        if let cell = collectionView.cellForItem(at: indexpath) as? AttachmentPreviewCell {
            cell.selectCell()
        }
    }
    
    // MARK: - Collection view functions
    // Number of items
    func numberOfItems() -> Int {
        let count = self.attachmentList.count
        self.updateBadgeCount?(count)
        return count
    }
    
    // Setup cell
    func updateCell(_ collectionView: UICollectionView, _ indexpath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AttachmentMemoViewModel.previewCellId, for: indexpath) as! AttachmentPreviewCell
        
        if let model = cacheList.object(forKey: NSNumber(integerLiteral: indexpath.row)) {
            // Exist, feed cell
            cell.UpdateCell(model: model)
        }
        else {
            // Not exist
            // Completion closure
            let completion: (AttachmentModel) -> () = { [weak self] model in
                guard let self = self else { return }
               
				self.loadedModel(cell, model, indexpath)
            }
            
            // Check existing operation
            if let operation = loadingOperations[indexpath] {
                // Found operation
                if operation.loaded {
                    // Loaded
					self.loadedModel(cell, operation.attachmentModel!, indexpath)
                }
                else {
                    // Loading
                    operation.completionHandler = completion
                }
            }
            else {
                // New operation
                let newOp = LoadAttachmentOperation(attachment: attachmentList[indexpath.row])
                newOp.completionHandler = completion
                // Add to operation queue
                loadingQueue.addOperation(newOp)
                loadingOperations[indexpath] = newOp
            }
        }
        return cell
    }
    
    // Select cell
    func selectCell(_ collectionView: UICollectionView, _ indexpath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexpath) as? AttachmentPreviewCell {
            if cell.isCellSelected {
                // Deselect
                cell.deselectCell()
                editingIndexes = editingIndexes.filter { $0 != indexpath }
            }
            else {
                // Select
                cell.selectCell()
                editingIndexes.append(indexpath)
            }
        }
    }
    
    // Prefetch
    func prefetch(_ indexpaths: [IndexPath]) {
        for indexpath in indexpaths {
            // Found existing operation loading for current cell, skip
            if let _ = loadingOperations[indexpath] {
                continue
            }
            
            // Create new operation for cell
            let newOp = LoadAttachmentOperation(attachment: attachmentList[indexpath.row])
            loadingQueue.addOperation(newOp)
            loadingOperations[indexpath] = newOp
        }
    }
    
    // Cancel prefetch
    func cancelFetch(_ indexpaths: [IndexPath]) {
        for indexpath in indexpaths {
            if let operation = loadingOperations[indexpath] {
                operation.cancel()
                loadingOperations.removeValue(forKey: indexpath)
            }
        }
    }
    
    // MARK: - Misc function
    // Get attachments
    func attachments() -> [AttachmentModel] {
        return self.attachmentList
    }
    
    // Is attachment empty
    func isAttchmentEmpty() -> Bool {
        return attachmentList.isEmpty
    }
}



// MARK: - Private functions
extension AttachmentMemoViewModel {
    // Loaded model at indexpath
	private func loadedModel(_ cell: AttachmentPreviewCell, _ model: AttachmentModel, _ indexpath: IndexPath) {
		print("loaded")
		// Feed cell
		cell.UpdateCell(model: model)
		// Reload cell
		self.reloadCellAtIndexpath?(indexpath)
		// Add to cache list
		self.cacheList.setObject(model, forKey: NSNumber(integerLiteral: indexpath.row))
		// Remove operation
		self.loadingOperations.removeValue(forKey: indexpath)
	}
    
    
    
}
