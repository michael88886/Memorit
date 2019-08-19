//
//  MemoViewController.swift
//  MemoIt
//
//  Created by mk mk on 6/6/19.
//  Copyright © 2019 MC2. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData

// Memo attachment type
enum AttachmentType: String {
	case image
	case audio
	
	var id: String {
		return self.rawValue
	}
}

struct MemoAttachment {
	var id: String
	var url: URL
	var type: AttachmentType
}

class AttachmentModel {
	// Cover image
	var image: UIImage
	init(image: UIImage) {
		self.image = image
	}
}

class VoiceAttachmentModel: AttachmentModel {	
	// Duration string
	var duration: String
	init(image: UIImage, duration: String) {
		self.duration = duration
		super.init(image: image)
	}
}

private enum TableRow: Int {
	case timeRow = 0
	case titleRow = 1
	case contentRow = 2
}

class MemoViewController: UIViewController {

	// MARK: - Properties
	// - Constants
	// Preview cell ID
	private let previewCellID: String = "PreviewCell"
	// Default bar button color
	private let btnTintColor: UIColor = #colorLiteral(red: 0.370555222, green: 0.3705646992, blue: 0.3705595732, alpha: 1)
	// Date label font
	private let dateFont: UIFont = UIFont.systemFont(ofSize:12, weight: .regular)
	// Attachment collection width
	private let acWidth: CGFloat = UIScreen.main.bounds.width * 0.4
	
	
	// - Variables
	// Attachment collection bottom constraint (keyboard show / hide)
	private var acBottomCst = NSLayoutConstraint()
	// Attachment collection right constraint (attachment collection show / hide)
	private var acRightCst = NSLayoutConstraint()
	// Attachment function container height
	private var acFuncH: CGFloat = 44
	// Attachment function container top constraint
	private var acTopCst = NSLayoutConstraint()
	// Attach collection showing flag
	private var isACShown: Bool = false
	// Attach collection edit mode
	private var isACEditing = false
	
	// - Data collcation
	// Attachments
	private var attachments: [MemoAttachment] = []
	// Editing indexpath
	private var editingIndexes: [IndexPath] = []
	// Deleting attachments
	private var deletingAttachments: [MemoAttachment] = []

	// - Prefetch (attachment)
	// Attachment loading operation queue
	private let loadingQueue = OperationQueue()
	// // Loading operations
	private var loadingOperations: [IndexPath: LoadPreviewAttachmentOperation] = [:]
	
	// - Core data
	// Memo ID
	private var memoID: String = Helper.uniqueName()
	// Memo directory
	private var memoDir: URL = FileManager.default.temporaryDirectory
	// Memo object
	private var memoData: AttachmentMemo?
	// Edit mode flag
	private var isEditMode: Bool = false
	// Save memo flag
	private var shouldSave = false
	
	
	// MARK: - Views
	// Right button
	private lazy var rightBadgeBtn: BadgeButton = {
		let button = BadgeButton(withNumber: 0)
		button.setImage(#imageLiteral(resourceName: "Pin44"), for: .normal)
		button.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
		button.addTarget(self, action: #selector(rightAction), for: .touchUpInside)
		return button
	}()
	
	// - Empty note label
	private lazy var emptyLabel: UILabel = {
		let label = UILabel()
		label.textAlignment = .center
		label.textColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
		label.font = UIFont.preferredFont(forTextStyle: .title1)
		label.text = "Empty note"
		return label
	}()
	
	// - Memo table view
	private lazy var memoTable: UITableView = {
		let table = UITableView(frame: CGRect.zero, style: .plain)
		table.allowsSelection = false
		table.allowsMultipleSelection = false
		table.keyboardDismissMode = .interactive
		table.estimatedRowHeight = 44
		table.rowHeight = UITableView.automaticDimension
		table.separatorStyle = .none
		return table
	}()
	
	// - Date label
	private lazy var dateLabel: UILabel = {
		let label = UIHelper.label(font: dateFont, textColor: #colorLiteral(red: 0.7540688515, green: 0.7540867925, blue: 0.7540771365, alpha: 1))
		label.textAlignment = .center
		label.text = String(format: "Editing: %@", CalendarHelper.dateToString(date: Date(), format: .memoTime))
		return label
	}()
	
	// - Time date cell
	private lazy var timeDateCell: UITableViewCell = {
		let cell = UITableViewCell()
		// Add date label to time cell
		dateLabel.translatesAutoresizingMaskIntoConstraints = false
		cell.contentView.addSubview(dateLabel)
		dateLabel.topAnchor.constraint(equalTo: cell.contentView.topAnchor).isActive = true
		dateLabel.leftAnchor.constraint(equalTo: cell.contentView.leftAnchor).isActive = true
		dateLabel.rightAnchor.constraint(equalTo: cell.contentView.rightAnchor).isActive = true
		dateLabel.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor).isActive = true
		return cell
	}()
	
	// - Title cell
	private lazy var titleCell: MemoTitleCell = MemoTitleCell(style: .default, reuseIdentifier: nil)

	// - Memo View
	private lazy var memoView: MKMemoview = {
		let textView = MKMemoview()
		textView.delegate = self
		return textView
	}()
	
	// - Content cell
	private lazy var contentCell: UITableViewCell = {
		let cell = UITableViewCell()
		// Add memo view
		memoView.translatesAutoresizingMaskIntoConstraints = false
		cell.contentView.addSubview(memoView)
		memoView.topAnchor.constraint(equalTo: cell.contentView.topAnchor).isActive = true
		memoView.leadingAnchor.constraint(equalTo: cell.contentView.safeAreaLayoutGuide.leadingAnchor, constant: Padding.p20).isActive = true
		memoView.trailingAnchor.constraint(equalTo: cell.contentView.safeAreaLayoutGuide.trailingAnchor, constant: -Padding.p20).isActive = true
		memoView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -Padding.p5).isActive = true
		return cell
	}()
	
	// - Attachment containter
	private lazy var acContainer = UIView()
	
	// - Attachment funtion container
	private lazy var acFunctionContainer = UIView()
	
	// - Delete attachment button
	private lazy var delAttBtn = UIHelper.button(icon: #imageLiteral(resourceName: "Bin32"), tint: #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1))
	
	// - Cancel edit button
	private lazy var cancelEditBtn = UIHelper.button(icon: #imageLiteral(resourceName: "Cross44"), tint: #colorLiteral(red: 0.6642242074, green: 0.6642400622, blue: 0.6642315388, alpha: 1))
	
	// - Attachment collection view
	private lazy var attCollection:UICollectionView = {
		// Layout
		let layout = UICollectionViewFlowLayout()
		layout.scrollDirection = .vertical
		
		// Collection view
		let collection = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
		collection.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
		collection.bounces = true
		collection.alwaysBounceVertical = true
		collection.contentInset = UIEdgeInsets(top: 5, left: 2, bottom: 5, right: 2)
		
		// Round corner
		collection.layer.cornerRadius = 4.0
		collection.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
		
		// Delegate, data source, register cell
		
		
		let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressOnAttrCollection(gesture:)))
		collection.addGestureRecognizer(longPress)
		
		return collection
	}()
	
	
	// MARK: - Custom init
	init(memo: AttachmentMemo?) {
		super.init(nibName: nil, bundle: nil)
		self.memoData = memo
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError()
	}
}

// MARK: - Override functions
extension MemoViewController {
	override func viewDidLoad() {
		super.viewDidLoad()
		// - Add notification observer
		// Show keyboard
		NotificationCenter.default.addObserver(self,
											   selector: #selector(keyboardAction(_:)),
											   name: UIResponder.keyboardWillShowNotification, object: nil)
		
		// Hide keyboard
		NotificationCenter.default.addObserver(self,
											   selector: #selector(keyboardAction(_:)),
											   name: UIResponder.keyboardWillHideNotification, object: nil)
	
		// - Add Gestures
		// Tap gesture on memo table
		let tap = UITapGestureRecognizer(target: self, action: #selector(tapOnTable(gesture:)))
		tap.delegate = self
		memoTable.addGestureRecognizer(tap)
		
		// Swipe right gesture
		let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swipeRightHandler(gesture:)))
		swipeRight.direction = .right
		view.addGestureRecognizer(swipeRight)
		
		// Right edge swipe gesture
		let rightEdgeSwipe = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(rightEdgeSwipeHandler(gesture:)))
		rightEdgeSwipe.edges = .right
		view.addGestureRecognizer(rightEdgeSwipe)
	}
	
	
} 


// MARK: - Private functions
extension MemoViewController {
	// MARK: Attachment collection functions
	// Add new attachment
	private func addAttachment(attachment: MemoAttachment) {
		attachments.append(attachment)
		rightBadgeBtn.updateCount(number: attachments.count)
		attCollection.reloadData()
	}
	
	// Attachment collection view editing mode
	private func editAttachment() {
		isACEditing = true
		print("Attachemtn eidt")
		// Show attachment editing container
		acTopCst.constant = -acFuncH
		UIView.animate(withDuration: 0.3) {
			self.acContainer.layoutIfNeeded()
		}
	}
	
	
	
	// MARK: Misc functions
	// Update date label
	private func updateEditDate(date: Date) {
		dateLabel.text = String(format: "Edited: %@", CalendarHelper.dateToString(date: date, format: .memoTime))
	}
	
	// Update keyboard accessory view state
	private func updateKeyboardAccessoryView(textView: UITextView) {
		if let accView = textView.inputAccessoryView {
			guard accView.isKind(of: KeyboardAccessoryView.self) else { return }
			let kbView = accView as! KeyboardAccessoryView
			kbView.updateState(attribute: textView.typingAttributes)
		}
	}
	
	// Image picker view controller
	private func imagePicker(type: UIImagePickerController.SourceType) -> UIImagePickerController {
		let picker = UIImagePickerController ()
		picker.sourceType = type
		picker.delegate = self
		
		switch picker.sourceType {
		case .camera:
			picker.cameraFlashMode = .auto
			picker.cameraCaptureMode = .photo
			picker.showsCameraControls = true
			
		case .photoLibrary:
			picker.allowsEditing = true
			
		default:
			()
		}
		
		return picker
	}
	
	// Convenience function to tint UIBarButtonItem
//	private func tintBarButtonsColor(buttons: [UIBarButtonItem], color: UIColor) {
//		for item in buttons {
//			item.tintColor = color
//		}
//	}
	
	// Calculate attachment cell size
	private func calculateCellSize() -> CGSize {
		// Flow layout
		let layout = attCollection.collectionViewLayout as! UICollectionViewFlowLayout
		// Left, right padding
		let padding = layout.minimumLineSpacing * 2
		// Cell size
		var size = attCollection.frame.width - padding
		// Minimum cell size is 0
		if size < 0 { size = 0 }
		return CGSize(width: size, height: size)
	}
	
//	// Go to Preview VC
//	private func previewAttachment(atIndex: Int) {
//		let previewVC = PreviewPageViewController(attachments: attachments, selectedIndex: atIndex)
//		let navi = UINavigationController(rootViewController: previewVC)
//		present(navi, animated: true, completion: nil)
//	}
} 

// MARK: - Actions
extension MemoViewController {
	// Left action (Save and exit)
	@objc private func leftAction() {
		// Hide keyboard
		self.view.endEditing(true)
		
		// FIXME: - Save
		
		// Dismiss VC
		dismiss(animated: true, completion: nil)
	}
	
	// Right action (Show / hide attachments)
	@objc private func rightAction() {
		if isACShown {
			// Hide attach collection view
			acRightCst.constant = acWidth
		}
		else {
			// Show attach collection view
			acRightCst.constant = 0
		}
		
		UIView.animate(withDuration: 0.2, animations: {
			self.view.layoutIfNeeded()
		}) { (finished) in
			self.isACShown = !self.isACShown
		}
	}
	
	// MARK: Keyboard actions
	@objc private func keyboardAction(_ notification: Notification) {
		guard let userInfo = notification.userInfo else { return }
		
		// Get system keyboard showing duration
		let duration: TimeInterval = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
		
		if notification.name == UIResponder.keyboardWillShowNotification {
			// SHow keyboard
			// Get keyboard height
			let rectValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
			let keyboardHeight = rectValue.cgRectValue.size.height
			
			// Adjust memo table bottom constraint
			acBottomCst.constant = -keyboardHeight + view.safeAreaInsets.bottom
		}
		else {
			// hide keyboard
			// Reset memo table bottom constraint
			acBottomCst.constant = 0
		}
		
		UIView.animate(withDuration: duration) {
			self.view.layoutIfNeeded()
		}
	}
	
	// MARK: Gesture handler functions
	// Handle tap gesture on tableview (Focus on text view)
	@objc private func tapOnTable(gesture: UITapGestureRecognizer) {
		// Touch point in memo table view
		let point = gesture.location(in: memoTable)
		// Index path for tocuh point
		let indexpath = memoTable.indexPathForRow(at: point)
		// If touch point is not on a cell
		if indexpath == nil && !memoView.isFirstResponder {
			memoView.becomeFirstResponder()
		}
	}
	
	// Swipe right handler (Hide attachment collection view)
	@objc private func swipeRightHandler(gesture: UISwipeGestureRecognizer) {
		if gesture.direction == .right,
			isACShown == true {
			acRightCst.constant = acWidth
			UIView.animate(withDuration: 0.2, animations: {
				self.view.layoutIfNeeded()
			}) { (finished) in
				self.isACShown = false
			}
		}
	}
	
	// Right edge swipe handler (Show attachment collection view)
	@objc private func rightEdgeSwipeHandler(gesture: UIScreenEdgePanGestureRecognizer) {
		
		// Attachment count must greater than 0
		guard attachments.count > 0 else { return }
		
		if gesture.edges == .right,
			isACShown == false {
			acRightCst.constant = 0
			UIView.animate(withDuration: 0.2, animations: {
				self.view.layoutIfNeeded()
			}) { (finished) in
				self.isACShown = true
			}
		}
	}
	
	// Handle long press gesture on attachment collection (Edit in attachment collection view)
	@objc private func longPressOnAttrCollection(gesture: UILongPressGestureRecognizer) {
		let point = gesture.location(in: attCollection)
		if let indexPath = attCollection.indexPathForItem(at: point) {
			switch gesture.state {
			case .began:
				if !isACEditing {
					// Show attachment editing container
					editAttachment()
					
					// Add editing indexpath
					editingIndexes.append(indexPath)
					
					// Selected cell to editing mode
					let cell = attCollection.cellForItem(at: indexPath) as? AttachmentPreviewCell
					if let cell = cell {
						cell.selectCell()
					}
				}
				gesture.state = .ended
			default:
				()
			}
		}
	}
	
	// MARK: Attachment edit functions
	// Cancel edit action
	@objc private func cancelEditAction() {
		print("cancel edit")
		// Hide attachment edit container
		acTopCst.constant = 0
		UIView.animate(withDuration: 0.2) {
			self.acContainer.layoutIfNeeded()
		}
		isACEditing = false
		
		// Remove all editing attachemnt
		for indexpath in editingIndexes {
			let cell = attCollection.cellForItem(at: indexpath) as? AttachmentPreviewCell
			if let cell = cell, cell.isCellSelected {
				cell.selectCell()
			}
		}
		editingIndexes.removeAll()
	}
	
	// Delete attachment action
	@objc private func delAttAction() {
		print("del att")
		// Remove selected item(s)
		for indexpath in editingIndexes {
			let attachment = attachments[indexpath.row]
			// Add item to deleting list
			deletingAttachments.append(attachment)
			// Remove item from attachments list
			attachments = attachments.filter { $0.id != attachment.id }
		}
		self.cancelEditAction()
		attCollection.reloadData()
		shouldSave = true
	}
} 

// MARK: - Delegates
// MARK: - UITableView data source / delegate
extension MemoViewController: UITableViewDataSource, UITableViewDelegate {
	// Number of rows
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 3
	}
	
	// Setup cell
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if let row = TableRow(rawValue: indexPath.row) {
			switch row {
			case .timeRow:
				return timeDateCell
			case .titleRow:
				return titleCell
			case .contentRow:
				return contentCell
			}
		}
		return UITableViewCell()
	}
}

// MARK: - CollectionView data source / delegate
extension MemoViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDataSourcePrefetching {
	// Number of cell
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return attachments.count
	}
	
	// Setup cell
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		<#code#>
	}
	
	// Select cell
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		<#code#>
	}
	
	// Cell size
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return calculateCellSize()
	}
	
	// Prefetch data
	func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
		
	}
	
	
}

// MARK: - UITextView delegate
extension MemoViewController: UITextViewDelegate {
	// Should begin edit
	func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
		// Remove empty label for text editing
		memoTable.backgroundView = nil
		
		// Input accessory view
		let width = UIScreen.main.bounds.width
		let height: CGFloat = 44.0
		let frame = CGRect(origin: CGPoint.zero, size: CGSize(width: width, height: height))
		let accBar = KeyboardAccessoryView(frame: frame)
		accBar.delegate = self
		textView.inputAccessoryView = accBar
		return true
	}
	
	// Begin edit
	func textViewDidBeginEditing(_ textView: UITextView) {
		updateKeyboardAccessoryView(textView: textView)
	}
	
	// End edit
	func textViewDidEndEditing(_ textView: UITextView) {
		// Remove input view
		textView.inputView = nil
		
		// Show empty label, if text is empty
		if memoView.text.isEmpty {
			memoTable.backgroundView = emptyLabel
		}
	}
	
	// Editing
	func textViewDidChange(_ textView: UITextView) {
		let size = textView.bounds.size
		let newSize = textView.sizeThatFits(CGSize(width: size.width, height: CGFloat.greatestFiniteMagnitude))
		// Resize the cell only when cell's size has changed
		if size.height != newSize.height {
			UIView.setAnimationsEnabled(false)
			memoTable.beginUpdates()
			memoTable.endUpdates()
			UIView.setAnimationsEnabled(true)
			
			if let thisIndexPath = memoTable.indexPath(for: contentCell) {
				memoTable.scrollToRow(at: thisIndexPath, at: .bottom, animated: true)
			}
		}
		
		// Update flag
		shouldSave = true
	}
	
	// Change selection
	func textViewDidChangeSelection(_ textView: UITextView) {
		print("change selection")
		updateKeyboardAccessoryView(textView: textView)
	}
}

// MARK: - UIGestureRecognizer delegate
extension MemoViewController: UIGestureRecognizerDelegate {
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		return true
	}
}

// MARK: - UIImagePickerViewController delegate
extension MemoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
		if let image = pickedImage {
			// Normailise image orientation
			let finalImage = Helper.normailzeOrientation(image: image)
			// Convert image to Data
			guard let pngData = finalImage.pngData() else { return }
			// Save image to disk and return URL
			if let imgURL = Helper.cacheImageData(pngData: pngData) {
				// Create new attachment for URL
				let id = imgURL.lastPathComponent
				let newAttach = MemoAttachment(id: id, url: imgURL, type: .image)
				addAttachment(attachment: newAttach)
				// Update bage button count
				rightBadgeBtn.updateCount(number: attachments.count)
				shouldSave = true
				picker.dismiss(animated: true, completion: nil)
			}
		}
	}
}

// MARK: - KeyboardAccessoryView delegate
extension MemoViewController: KeyboardAccessoryViewDelegate {
	func drawing() {
		// Hide keyboard
		view.endEditing(true)
		
	}
	
	func recorder() {
		// Hide keyboard
		view.endEditing(true)
		
	}
	
	func album() {
		let picker = imagePicker(type: .photoLibrary)
		present(picker, animated: true, completion: nil)
	}
	
	func camera() {
		let picker = imagePicker(type: .camera)
		present(picker, animated: true, completion: nil)
	}
	
	func boldText(activate: Bool) {
		memoView.boldtext(isBold: activate)
	}
	
	func italicText(activate: Bool) {
		memoView.italicText(isItalic: activate)
	}
	
	func underlineText(activate: Bool) {
		memoView.underlineText(isUnderline: activate)
	}
	
	func strikeThoughText(activate: Bool) {
		memoView.strikeThroughText(isStrikeThrough: activate)
	}
}


// MARK: - Setup UI
extension MemoViewController {
	override func loadView() {
		super.loadView()
		// Backgroud color
		view.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
		
		// Navigation bar
		navigationController?.setNavigationBarHidden(false, animated: false)
		navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1),
																   NSAttributedString.Key.font: UIFont.systemFont(ofSize: 24)]
		navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
		navigationController?.navigationBar.shadowImage = UIImage()
		
		// Navigation buttons
		// - Left button
		let leftBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "NaviBack44"), style: .plain, target: self, action: #selector(leftAction))
		leftBtn.tintColor = btnTintColor
		navigationItem.leftBarButtonItem = leftBtn
		
		// - Right button
		let rightBtn = UIBarButtonItem(customView: rightBadgeBtn)
		navigationItem.rightBarButtonItem = rightBtn
		
		// Title
		title = "Memo"
		
		// Hide tool bar
		navigationController?.isToolbarHidden = true
		
		// Navigation separator
		let naviSep = UIHelper.separator(withColor: #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1))
		view.addSubview(naviSep)
		naviSep.translatesAutoresizingMaskIntoConstraints = false
		naviSep.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
		naviSep.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Padding.p20).isActive = true
		naviSep.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: Padding.p20).isActive = true
		naviSep.heightAnchor.constraint(equalToConstant: 1).isActive = true
		
		// Attachment container
		acContainer.clipsToBounds = true
		view.addSubview(acContainer)
		acContainer.translatesAutoresizingMaskIntoConstraints = false
		acContainer.topAnchor.constraint(equalTo: naviSep.bottomAnchor, constant: Padding.p5).isActive = true
		acContainer.widthAnchor.constraint(equalToConstant: acWidth).isActive = true
		acRightCst = acContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: acWidth)
		acRightCst.isActive = true
		acBottomCst = acContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
		acBottomCst.isActive = true
		
		// Attachment title
		let acTitle = UILabel()
		acTitle.textColor = #colorLiteral(red: 0.6642242074, green: 0.6642400622, blue: 0.6642315388, alpha: 1)
		acTitle.textAlignment = .center
		acTitle.font = UIFont.preferredFont(forTextStyle: .body)
		acTitle.text = "Attachments"
		acContainer.addSubview(acTitle)
		acTitle.translatesAutoresizingMaskIntoConstraints = false
		acTitle.topAnchor.constraint(equalTo: acContainer.topAnchor).isActive = true
		acTitle.centerXAnchor.constraint(equalTo: acContainer.centerXAnchor).isActive = true
		
		// Attachment function container
		//        acFunctionContainer.backgroundColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
		acContainer.addSubview(acFunctionContainer)
		acFunctionContainer.translatesAutoresizingMaskIntoConstraints = false
		acFunctionContainer.leadingAnchor.constraint(equalTo: acContainer.leadingAnchor).isActive = true
		acFunctionContainer.trailingAnchor.constraint(equalTo: acContainer.trailingAnchor).isActive = true
		acFunctionContainer.heightAnchor.constraint(equalToConstant: acFuncH).isActive = true
		acTopCst = acFunctionContainer.topAnchor.constraint(equalTo: acContainer.bottomAnchor)
		acTopCst.isActive = true
		
		// Attachment function separator
		let sepFunc = UIHelper.separator(withColor: #colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1))
		acFunctionContainer.addSubview(sepFunc)
		sepFunc.translatesAutoresizingMaskIntoConstraints = false
		sepFunc.widthAnchor.constraint(equalTo: acFunctionContainer.widthAnchor, multiplier: 0.9).isActive = true
		sepFunc.heightAnchor.constraint(equalToConstant: 1).isActive = true
		sepFunc.centerXAnchor.constraint(equalTo: acFunctionContainer.centerXAnchor).isActive = true
		sepFunc.topAnchor.constraint(equalTo: acFunctionContainer.topAnchor).isActive = true
		
		// Attachment delete button
		delAttBtn.addTarget(self, action: #selector(delAttAction), for: .touchUpInside)
		acFunctionContainer.addSubview(delAttBtn)
		delAttBtn.translatesAutoresizingMaskIntoConstraints = false
		delAttBtn.topAnchor.constraint(equalTo: sepFunc.bottomAnchor).isActive = true
		delAttBtn.leadingAnchor.constraint(equalTo: acFunctionContainer.leadingAnchor).isActive = true
		delAttBtn.trailingAnchor.constraint(equalTo: acFunctionContainer.centerXAnchor).isActive = true
		delAttBtn.bottomAnchor.constraint(equalTo: acFunctionContainer.bottomAnchor).isActive = true
		
		// Attachment edit button
		acFunctionContainer.addSubview(cancelEditBtn)
		cancelEditBtn.translatesAutoresizingMaskIntoConstraints = false
		cancelEditBtn.topAnchor.constraint(equalTo: sepFunc.bottomAnchor).isActive = true
		cancelEditBtn.leadingAnchor.constraint(equalTo: acFunctionContainer.centerXAnchor).isActive = true
		cancelEditBtn.trailingAnchor.constraint(equalTo: acFunctionContainer.trailingAnchor).isActive = true
		cancelEditBtn.bottomAnchor.constraint(equalTo: acFunctionContainer.bottomAnchor).isActive = true
		
		// Attachment collection view
		attCollection.dataSource = self
		attCollection.delegate = self
		attCollection.prefetchDataSource = self
		attCollection.register(AttachmentPreviewCell.self, forCellWithReuseIdentifier: previewCellID)
		acContainer.addSubview(attCollection)
		attCollection.translatesAutoresizingMaskIntoConstraints = false
		attCollection.topAnchor.constraint(equalTo: acTitle.bottomAnchor).isActive = true
		attCollection.leadingAnchor.constraint(equalTo: acContainer.leadingAnchor).isActive = true
		attCollection.trailingAnchor.constraint(equalTo: acContainer.trailingAnchor).isActive = true
		attCollection.bottomAnchor.constraint(equalTo: acFunctionContainer.topAnchor).isActive = true
		
		// Separator
		let sep = UIHelper.separator(withColor: #colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1))
		view.addSubview(sep)
		sep.translatesAutoresizingMaskIntoConstraints = false
		sep.widthAnchor.constraint(equalToConstant: 1).isActive = true
		sep.heightAnchor.constraint(equalTo: attCollection.heightAnchor, multiplier: 0.9).isActive = true
		sep.leadingAnchor.constraint(equalTo: attCollection.leadingAnchor).isActive = true
		sep.centerYAnchor.constraint(equalTo: attCollection.centerYAnchor).isActive = true
		
		// Memo table view
		memoTable.dataSource = self
		memoTable.delegate = self
		view.addSubview(memoTable)
		memoTable.translatesAutoresizingMaskIntoConstraints = false
		memoTable.topAnchor.constraint(equalTo: naviSep.bottomAnchor, constant: Padding.p5).isActive = true
		memoTable.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
		memoTable.trailingAnchor.constraint(equalTo: attCollection.leadingAnchor).isActive = true
		memoTable.bottomAnchor.constraint(equalTo: attCollection.bottomAnchor).isActive = true
	}
}
