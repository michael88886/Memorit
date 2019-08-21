//
//  MemoAttachmentModel.swift
//  MemoIt
//
//  Created by MICA17 on 19/8/19.
//  Copyright © 2019 MC2. All rights reserved.
//

import UIKit
import CoreData

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
	private(set) var attributString: NSAttributedString?
	// Memo directory
	private var memoDir: URL = FileManager.default.temporaryDirectory
	// Memo ID
	private var memoID: String = Helper.uniqueName()
	// Memo color
	private var memoColor: UIColor = .white
	// Memo object
	private var memoData: AttachmentMemo?
	// Edit mode flag
	private var isEditMode: Bool = false
	// Should save flag
	private var shouldSave: Bool = false
	
	
    // Attachment list (store attachment)
    private var attachmentList = [AttachmentModel]()
    // Cache list (cache loaded attachments for collection cell)
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
	// MARK: Save load function
	// Save memo
	func saveMemo() {
		if !shouldSave { return }
		
		// Data context
		let context = Helper.dataContext()
		// Memo object
		var memoObject: AttachmentMemo!
		// File manager
		let fileManager = FileManager.default
		
		context.perform {
			// Memo title
			if self.memoTitle.trimmingCharacters(in: .whitespaces) == "" {
				self.memoTitle = "New note"
			}
			
			// Memo directory
			self.memoDir = Helper.memoDirectory().appendingPathComponent(self.memoID)
			
			// If is new memo, move attachments to directory
			if !fileManager.fileExists(atPath: self.memoDir.path) {
				do {
					try fileManager.createDirectory(at: self.memoDir, withIntermediateDirectories: true, attributes: nil)
				}
				catch {
					print("Failed to create directory: \(error.localizedDescription)")
				}
			}
			
			// Deleting attachment from delete list
			do {
				for item in self.deletingAttachments {
					try fileManager.removeItem(at: item.directory)
				}
			}
			catch {
				print("Failed to delete attachments: \(error.localizedDescription)")
			}
			
			// Move attachment to destination
			for attach in self.attachmentList {
				let currURL = attach.directory
				let destURL = self.memoDir.appendingPathComponent(attach.filename)
				
				if currURL != destURL {
					do {
						try fileManager.moveItem(at: currURL, to: destURL)
					}
					catch {
						print("Failed to move attachment: \(error.localizedDescription)")
					}
				}
			}
			
			// Clear temporary directory
			Helper.clearTmpDirectory()
			
			// Save to core data
			if self.isEditMode {
				// Editing
				let objID: NSManagedObjectID = (self.memoData?.objectID)!
				do {
					try memoObject = context.existingObject(with: objID) as? AttachmentMemo
				}
				catch {
					print("\(self) Failed to get object from ID: \(error.localizedDescription)")
				}
				
				// Empty current attachments
				memoObject.attachments = nil
			}
			else {
				// New memo
				let entry = NSEntityDescription.entity(forEntityName: "AttachmentMemo", in: context)!
				memoObject = NSManagedObject(entity: entry, insertInto: context) as? AttachmentMemo
			}
			
			// Title
			memoObject.setValue(self.memoTitle, forKey: "title")
			// MemoID
			memoObject.setValue(self.memoID, forKey: "memoID")
			// Modified time
			memoObject.setValue(Date(), forKey: "timeModified")
			// Archived flag
			memoObject.setValue(false, forKey: "archived")
			// Color
			memoObject.setValue(self.memoColor, forKey: "color")
			// Attribute string
			memoObject.setValue(self.attributString, forKey: "attributedString")
			// Type
			memoObject.setValue(MemoType.attach.rawValue, forKey: "type")
			
			// Attachments
			for attach in self.attachmentList {
				// Attachment entity
				let attcEntity = NSEntityDescription.entity(forEntityName: "Attachment", in: context)!
				// Attachment object
				let attcObj = NSManagedObject(entity: attcEntity, insertInto: context) as! Attachment
				attcObj.setValue(attach.filename, forKey: "attachID")
				attcObj.setValue(attach.type.id, forKey: "attachType")
				memoObject.addToAttachments(attcObj)
			}
			
			// Save context
			do {
				try context.save()
			}
			catch {
				print("\(self) Failed to save data: \(error.localizedDescription)")
				return
			}
			
			// Refresh context
			context.refreshAllObjects()
			// Send notification
			NotificationCenter.default.post(name: .reloadHomeList, object: nil)
		}
	}
	
	// Load memo
	func loadMemo(memo: AttachmentMemo) {
		// Assign object
		self.memoData = memo
		self.isEditMode = true
		
		// Update memo color
		self.memoColor = memo.color
		
		// Update file name
		self.memoID = memo.memoID
		
		// Update directory
		self.memoDir = Helper.memoDirectory().appendingPathComponent(memo.memoID)
		
		// Attribute text
		self.attributString = memo.attributedString
		
		// Load attachments
		guard let atts = memo.attachments else { return }
		
		if atts.count > 0 {
			for att in atts {
				if let attach = att as? Attachment {
					// Attachment URL
					let attDir = self.memoDir.appendingPathComponent(attach.attachID)
					// Attachment type
					let attType = AttachmentType(rawValue: attach.attachType)!
					// Create attachment model
					let newAttachment = AttachmentModel(fileName: attach.attachID, directory: attDir, type: attType)
					attachmentList.append(newAttachment)
				}
			}
		}
	}
	
	// MARK: Update memo title
	func updateMemoTitle(title: String?) {
		if let titleStr = title {
			self.memoTitle = titleStr
			shouldSave = true
		}
	}
	
	// MARK: Attribute string function
	func updateAttributeString(attrStr: NSAttributedString?) {
		self.attributString = attrStr
		shouldSave = true
	}
	
    // MARK: Attachment editing functions
    // Add attachment
    func addAttachment(_ attachment: AttachmentModel) {
        attachmentList.append(attachment)
        self.reloadCollection?()
		shouldSave = true
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
		
		shouldSave = true
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
    
    // MARK: Collection view functions
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
