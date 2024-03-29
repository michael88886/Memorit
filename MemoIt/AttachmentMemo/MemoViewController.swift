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
    // Attachment model
	private var memoViewModel: AttachmentMemoViewModel
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
		cell.contentView.addSubview(dateLabel)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
		dateLabel.topAnchor.constraint(equalTo: cell.contentView.topAnchor).isActive = true
		dateLabel.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor).isActive = true
		dateLabel.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor).isActive = true
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
		cell.contentView.addSubview(memoView)
		memoView.translatesAutoresizingMaskIntoConstraints = false
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
	private lazy var delAttBtn = UIHelper.button(icon: #imageLiteral(resourceName: "Bin44"), tint: #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1))
	
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
		
		let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressOnAttrCollection(gesture:)))
		collection.addGestureRecognizer(longPress)
		
		return collection
	}()
	
	
	// MARK: - Custom init
	init(memo: AttachmentMemo?) {
		// Initialize view model
		memoViewModel = AttachmentMemoViewModel(memo: memo)
		super.init(nibName: nil, bundle: nil)
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
		
		// - Assign attachment view model closures
		// Reolad collection view
		memoViewModel.reloadCollection = reloadCollection
		// Reload cell at indexpath
		memoViewModel.reloadCellAtIndexpath = reloadAtIndexpath
		// Update badge button
		memoViewModel.updateBadgeCount = updateBadgeCount
		// No more attachment, hide attachment collection view
		memoViewModel.noMoreAttachment = noAttachment
		
		// - Assign title cell closure
		titleCell.updateTitle = updateTitle
		
		// Load data
		memoViewModel.loadMemo()
		
		// Set title
		titleCell.setTitle(title: memoViewModel.memoTitle)
		// Set text
		memoView.attributedText = memoViewModel.attributString
		
		if memoView.text.isEmpty {
			memoTable.backgroundView = emptyLabel
		}
	}
}

// MARK: - Private functions
extension MemoViewController {
	// MARK: Closure functions
	// Reload collectiom
	private func reloadCollection() {
		attCollection.reloadData()
		
		
	}
	
	// Reload cell at indexpath
	private func reloadAtIndexpath(indexpath: IndexPath) {
		attCollection.reloadItems(at: [indexpath])
	}
	
	// Update badge button count
	private func updateBadgeCount(count: Int) {
		rightBadgeBtn.updateCount(number: count)
	}
	
	// No attachment
	private func noAttachment() {
		if isACShown {
			hideAttachmentCollection()
		}
	}
	
	// Update title
	private func updateTitle(title: String?) {
		memoViewModel.updateMemoTitle(title: title)
	}
	
	
	// MARK: Save attachment functions
	// Save audio attachment
	private func saveAudioAttachment(url: URL) {
		// Create new attachment
		let newAttachment = AttachmentModel(fileName: url.lastPathComponent, directory: url, type: .audio)
		memoViewModel.addAttachment(newAttachment)
		if isACShown == false {
			showAttachmentCollection()
		}
	}
	
	// Save image attachment
	private func saveImageAttachment(image: UIImage) {
		guard let imageData = image.pngData() else { return }
		if let imageURL = Helper.cacheImageData(pngData: imageData) {
			let filename = imageURL.lastPathComponent
			let newAttachment = AttachmentModel(fileName: filename, directory: imageURL, type: .image)
			memoViewModel.addAttachment(newAttachment)
			if isACShown == false {
				showAttachmentCollection()
			}
		}
	}
	
	// MARK: Attachment collection functions
	// Attachment collection view editing mode
	private func editAttachment() {
		isACEditing = true
		// Show attachment editing container
		acTopCst.constant = -acFuncH
		UIView.animate(withDuration: 0.3) {
			self.acContainer.layoutIfNeeded()
		}
	}
	
	// Show attachment collection
	private func showAttachmentCollection() {
		acRightCst.constant = 0
		UIView.animate(withDuration: 0.2, animations: {
			self.view.layoutIfNeeded()
		}) { (finished) in
			self.isACShown = true
		}
	}
	
	// Hide attachment collection
	private func hideAttachmentCollection() {
		acRightCst.constant = acWidth
		UIView.animate(withDuration: 0.2, animations: {
			self.view.layoutIfNeeded()
		}) { (finished) in
			self.isACShown = false
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
	
    // Go to Preview VC
    private func previewAttachment(_ attachments: [AttachmentModel], atIndex: Int) {
        let previewVC = PreviewPageViewController(attachments: attachments, selectedIndex: atIndex)
        let navi = UINavigationController(rootViewController: previewVC)
        present(navi, animated: true, completion: nil)
    }
}

// MARK: - Actions
extension MemoViewController {
	// Left action (Save and exit)
	@objc private func leftAction() {
		// Hide keyboard
		self.view.endEditing(true)
		// Save memo
		memoViewModel.saveMemo()
		
		// Dismiss VC
		navigationController?.popViewController(animated: true)
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
			hideAttachmentCollection()
		}
	}
	
	// Right edge swipe handler (Show attachment collection view)
	@objc private func rightEdgeSwipeHandler(gesture: UIScreenEdgePanGestureRecognizer) {
		// Attachment must not empty
		guard memoViewModel.isAttchmentEmpty() == false else { return }
		
		if gesture.edges == .right,
			isACShown == false {
			showAttachmentCollection()
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
					memoViewModel.addEditingIndex(attCollection, indexPath)
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
		// Hide attachment edit container
		acTopCst.constant = 0
		UIView.animate(withDuration: 0.2) {
			self.acContainer.layoutIfNeeded()
		}
		isACEditing = false
		
        // Clear editing attachments
		memoViewModel.clearEditingAttachment(attCollection)
	}
	
	// Delete attachment action
	@objc private func delAttAction() {
        // Delete selected attachments
        memoViewModel.deleteAttachments()
        
		self.cancelEditAction()
		attCollection.reloadData()
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
		return memoViewModel.numberOfItems()
	}
	
	// Setup cell
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		return memoViewModel.updateCell(collectionView, indexPath)
	}
	
	// Select cell
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isACEditing {
            // Editing
            memoViewModel.selectCell(collectionView, indexPath)
        }
        else {
            // Normal
            previewAttachment(memoViewModel.attachments(), atIndex: indexPath.row)
        }
	}
	
	// Cell size
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return calculateCellSize()
	}
	
	// Prefetch data
	func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
		memoViewModel.prefetch(indexPaths)
	}
	
    // Cancel prefetch
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        memoViewModel.cancelFetch(indexPaths)
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
		
		memoViewModel.updateAttributeString(attrStr: textView.attributedText)
		
		if textView.text.isEmpty {
			memoTable.backgroundView = emptyLabel
		}
		else {
			memoTable.backgroundView = nil
		}
	}
	
	// Change selection
	func textViewDidChangeSelection(_ textView: UITextView) {
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
			// Save image
			saveImageAttachment(image: finalImage)
			picker.dismiss(animated: true, completion: nil)
		}
	}
}

// MARK: - KeyboardAccessoryView delegate
extension MemoViewController: KeyboardAccessoryViewDelegate {
	func drawing() {
		// Hide keyboard
		view.endEditing(true)
		// To drawing board
		let drawingVC = DrawingViewController()
		drawingVC.saveDrawing = saveImageAttachment
		navigationController?.pushViewController(drawingVC, animated: true)
	}
	
	func recorder() {
		// Hide keyboard
		view.endEditing(true)
		// To voice recorder
		let voiceVC = VoiceViewController(type: .attachment)
		voiceVC.saveAudio = saveAudioAttachment
		navigationController?.pushViewController(voiceVC, animated: true)
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
		cancelEditBtn.addTarget(self, action: #selector(cancelEditAction), for: .touchUpInside)
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
