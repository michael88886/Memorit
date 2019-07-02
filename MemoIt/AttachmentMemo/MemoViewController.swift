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
	// Default bar button color
	private let btnTintColor: UIColor = #colorLiteral(red: 0.370555222, green: 0.3705646992, blue: 0.3705595732, alpha: 1)
	// Date label font
	private let dateFont: UIFont = UIFont.systemFont(ofSize:12, weight: .regular)
	// Attachment collection width
	private let acWidth: CGFloat = UIScreen.main.bounds.width * 0.4
	// Attachment collection bottom constraint (keyboard show / hide)
	private var acBottomCst = NSLayoutConstraint()
	// Attachment collection right constraint (attachment collection show / hide)
	private var acRightCst = NSLayoutConstraint()
	// Attachment function container height
	private var acFuncH: CGFloat = 44
	// Attachment function container top constraint
	private var acTopCst = NSLayoutConstraint()

	// - Attachment collection view
	// Preview cell ID
	private let previewCellID: String = "PreviewCell"
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
	
	/*
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
		table.dataSource = self
		table.delegate = self
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
		memoView.leftAnchor.constraint(equalTo: cell.contentView.safeAreaLayoutGuide.leftAnchor, constant: UIHelper.Padding.p20).isActive = true
		memoView.rightAnchor.constraint(equalTo: cell.contentView.safeAreaLayoutGuide.rightAnchor, constant: -UIHelper.Padding.p20).isActive = true
		memoView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -UIHelper.Padding.p5).isActive = true
		return cell
	}()
	
	// - Attachment containter
	private lazy var acContainer = UIView()
	
	// - Attachment funtion container
	private lazy var acFunctionContainer = UIView()
	
	// - Delete attachment button
	private lazy var delAttBtn: UIButton = {
		let btn = UIHelper.button(icon: #imageLiteral(resourceName: "Bin"), tint: #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1))
		btn.addTarget(self, action: #selector(delAttAction), for: .touchUpInside)
		return btn
	}()
	
	// - Cancel edit button
	private lazy var cancelEditBtn: UIButton = {
		let btn = UIHelper.button(icon: #imageLiteral(resourceName: "Cross"), tint: #colorLiteral(red: 0.6642242074, green: 0.6642400622, blue: 0.6642315388, alpha: 1))
		btn.addTarget(self, action: #selector(cancelEditAction), for: .touchUpInside)
		return btn
	}()
	
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
		collection.dataSource = self
		collection.delegate = self
		collection.prefetchDataSource = self
		collection.register(AttachmentPreviewCell.self, forCellWithReuseIdentifier: previewCellID)
		
		let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressOnAttrCollection(gesture:)))
		collection.addGestureRecognizer(longPress)
		
		return collection
	}()
	
	// MARK: - Convenience init
	convenience init(memo: AttachmentMemo?) {
		self.init()
		self.memoData = memo
	}

  */
}

/*
// MARK: - Private functions
extension MemoViewController {} 

// MARK: - Actions
extension MemoViewController {
	// Left action (Save and exit)
	@objc private func leftACtion() {
		
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
} 

// MARK: - Override functions
extension MemoViewController {
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Do any additional setup after loading the view.
	}
	
	override func loadView() {
		super.loadView()
		
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
*/
// MARK: - 
