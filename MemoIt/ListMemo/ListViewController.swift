//
//  ListViewController.swift
//  MemoIt
//
//  Created by mk mk on 6/6/19.
//  Copyright © 2019 MC2. All rights reserved.
//

import UIKit
import CoreData

// MARK: - List model
struct ListModel {
	var title: String
	var isDone: Bool
	var color: UIColor
	var reminder: Date?
	
	// Initializer
	init(title: String) {
		self.title = title
		self.isDone = false
		self.color = .clear
		self.reminder = nil
	}
}

// MARK: - List controller
class ListViewController: UIViewController {

	// MARK: - Properties
	// - Constants
	// Cell ID
	private let cellID = "ListCell"
	// Title field height
	private let titleH: CGFloat = 44
	// Summary view height
	private let summaryVH: CGFloat = 88
	// State block size
	private let stateBlkH: CGFloat = 72
	
	// - Data collection
	// List items
	private var listItems: [ListModel] = []
	// List memo object reference
	private var memoData: ListMemo?
	
	// - Variables
	// Table bottom constraint
	private var listBottomCst = NSLayoutConstraint()
	// Should save flag
	private var shouldSave: Bool = false
	// Is editing mode flag
	private var isEditingMode: Bool = false
	
	// - Reference
	// Current editing cell reference
	private var editingCell: ListTableCell?
	// Data object reference
	private var listData: ListMemo?
	

	// MARK: - Views
	// - Title field
	private lazy var titleField: UITextField = {
		let tf = UITextField()
		tf.placeholder = "Add title"
		tf.font = UIFont.systemFont(ofSize: 24, weight: .regular)
		tf.tintColor = #colorLiteral(red: 0.6642242074, green: 0.6642400622, blue: 0.6642315388, alpha: 1)
		tf.textColor = UIHelper.defaultTint
		return tf
	}()
	
	// - Summary view
	private lazy var summaryView: UIView = {
		let sv = UIView()
		sv.backgroundColor = .white
		
		// Shadow
		sv.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
		sv.layer.shadowOpacity = 0.1
		sv.layer.shadowRadius = 2.0
		sv.layer.shadowOffset = CGSize(width: 0, height: -2)
		return sv
	}()
	
	// Total state (Total tasks)
	private lazy var totalState = StatusView(title: "Total")
	
	// Finish state (Tasks done)
	private lazy var finishState = StatusView(title: "Completed")
	
	// Progress state (Complete percentage)
	private lazy var progressState = StatusView(title: "Progress")
	
    // - Refresh control
    private lazy var refreshControl: UIRefreshControl = {
        let rf = UIRefreshControl()
        
        return rf
    }()
    
	// - List table
	private lazy var listTable: UITableView = {
		let table = UITableView(frame: CGRect.zero, style: .plain)
		table.backgroundColor = .clear
		table.allowsSelection = false
		table.allowsMultipleSelection = false
		table.isMultipleTouchEnabled = false
		table.separatorStyle = .none
		table.keyboardDismissMode = .interactive
		table.rowHeight = UITableView.automaticDimension
		table.estimatedRowHeight = 96
		
		table.dataSource = self
		table.delegate = self
		table.register(ListTableCell.self, forCellReuseIdentifier: cellID)
		return table
	}()
	
	
	// MARK: - Convenience init
	convenience init(memo: ListMemo?) {
		self.init()
		self.memoData = memo
	}
}

// MARK: - Private function
extension ListViewController {
	// MARK: - Save & Load (💾 / 🚚)
	private func saveList() {
		print("Save list")
		// Data context
		let context = Helper.dataContext()
		// List object
		var listObject: ListMemo!
		// Default title name
		var titleName = "New list"
		// Memo type
		//        let memoType = MemoType.list.id
		
		context.perform {
			// Memo title
			if let title = self.titleField.text, 
				title != "" {
				titleName = title
			}
			
			// Save to core data
			if self.isEditingMode {
				// Editing
				let objID: NSManagedObjectID = (self.listData?.objectID)!
				do {
					try listObject = context.existingObject(with: objID) as? ListMemo
				}
				catch {
					print("\(self) Failed to get object from ID")
				}
				listObject.listItem = nil
			}
			else {
				// New
				let entity = NSEntityDescription.entity(forEntityName: "ListMemo", in: context)!
				listObject = NSManagedObject(entity: entity, insertInto: context) as? ListMemo
			}
			
			// Title
			listObject.setValue(titleName, forKey: "title")
			// Modified time
			listObject.setValue(Date(), forKey: "timeModified")
			// Archived flag
			listObject.setValue(false, forKey: "archived")
			// Color
			listObject.setValue(UIColor.white, forKey: "color")
			// Type
			listObject.setValue(MemoType.todo.rawValue, forKey: "type")
			
			// List items
			for item in self.listItems {
				let itemEntity = NSEntityDescription.entity(forEntityName: "ListItem", in: context)!
				let itemObj = NSManagedObject(entity: itemEntity, insertInto: context) as! ListItem
				// Color
				itemObj.setValue(item.color, forKey: "color")
				// Complete state
				itemObj.setValue(item.isDone, forKey: "isDone")
				// Item title
				itemObj.setValue(item.title, forKey: "title")
				// Reminder
				itemObj.setValue(item.reminder, forKey: "reminder")
				listObject.addToListItem(itemObj)
			}
			
			// Save object
			do {
				try context.save()
			}
			catch {
				print("\(self): Failed to save data: ", error.localizedDescription)
				return
			}
			context.refreshAllObjects()
			
			
			// FIXME: - push notification notice for update
			NotificationCenter.default.post(name: .newItemHomeTable, object: nil)
		}
	}
	
	private func loadList() {
		print("load list")
		if let data = listData {
			// Assign object
			listData = data
			// Load ttile
			titleField.text = data.title
			// Load memo items
			if let items = data.listItem,
				items.count > 0 {
				for item in items {
					let itm = item as? ListItem
					if let itm = itm {
						var itmModel = ListModel(title: itm.title)
						itmModel.color = itm.color
						itmModel.isDone = itm.isDone
						itmModel.title = itm.title
						itmModel.reminder = itm.reminder as Date?
					}
				}
				// Refresh data
				listTable.reloadData()
			}
		}
	}
	
	// MARK: - Keyboard funcitons
	// - Keyboard will show
	@objc private func keyboardWillShow(notification: NSNotification) {
		// User info from nitification
		guard let userInfo = notification.userInfo else { return }
		// Get system keyboard showing duration
		let duration: TimeInterval = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
		// Get keyboard height
		let rectValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
		let keyboardHeight = rectValue.cgRectValue.size.height
		
		// Adjust memo table bottom constraint
		listBottomCst.constant = -keyboardHeight + view.safeAreaInsets.bottom + summaryVH
		// Perform animation
		UIView.animate(withDuration: duration) {
			self.view.layoutIfNeeded()
		}
	}
	
	// - Keyboard will hide
	@objc private func keyboardWillHide(notification: NSNotification) {
		// User info from notification
		guard let userInfo = notification.userInfo else { return }
		
		// Get system keyboard hiding duration
		let duration: TimeInterval = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
		
		// Reset memo table bottom constraint
		listBottomCst.constant = 0
		UIView.animate(withDuration: duration) {
			self.view.layoutIfNeeded()
		}
		navigationItem.rightBarButtonItem = nil
	}
	
}

// MARK: - Closure functions
extension ListViewController {
	// - Cell start editng
	private func startEditing(_ cell: ListTableCell) {
		// Assign editing cell
		editingCell = cell
	}
	
	// - Editing cell text
	private func editintCelltext(_ cell: ListTableCell) {
		shouldSave = true
		// Keep track and update cell size
		UIView.setAnimationsEnabled(false)
		listTable.beginUpdates()
		listTable.endUpdates()
		UIView.setAnimationsEnabled(true)
	}
	
	// - Cell end editing
	private func endEditing(_ cell: ListTableCell) {}
	
	// - Refresh cell
	private func refreshCell(_ cell: ListTableCell, text: String) {
		let indexpath = listTable.indexPath(for: cell)
		if let indexpath = indexpath {
			// Update model
			listItems[indexpath.row].title = text
			
			// Reload cell
			listTable.reloadRows(at: [indexpath], with: .automatic)
		}
	}
	
	// - Add new item
	private func addItem(title: String) {
		// Add item
		let newItem = ListModel(title: title)
		listItems.append(newItem)
		// Reload table
		listTable.reloadData()
	}
	
	// - Change item complete state
	private func taskCompleted(_ cell: ListTableCell, isDone: Bool) {
		let indexpath = listTable.indexPath(for: cell)
		if let indexpath = indexpath {
			if isDone {
				listItems[indexpath.row].isDone = isDone
			}
			else {
				listItems[indexpath.row].isDone = isDone
			}
		}
	}
}

// MARK: - Actions
extension ListViewController {
	// Back button action
	@objc private func backAction() {
		// Save function
		saveList()
		// Hide keyboard
		titleField.resignFirstResponder()
		
		if let cell = editingCell {
			cell.hideKeyboard()
		}
		
		// Dismiss VC
		navigationController?.popViewController(animated: true)
	}
}

// MARK: - Override functions
extension ListViewController {
	override func viewDidLoad() {
		super.viewDidLoad()
		// Keyboard show / hide notification
		// - Keyboard will show
		NotificationCenter.default.addObserver(self,
											   selector: #selector(keyboardWillShow(notification:)),
											   name: UIResponder.keyboardWillShowNotification, object: nil)
		// - Keyboard will hide
		NotificationCenter.default.addObserver(self,
											   selector: #selector(keyboardWillHide(notification:)),
											   name: UIResponder.keyboardWillHideNotification, object: nil)
	}
	
	override func loadView() {
		super.loadView()
		
		// Background color
		view.backgroundColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
		
		// Navigation bar
		navigationController?.setNavigationBarHidden(false, animated: false)
		navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1),
																   NSAttributedString.Key.font: UIFont.systemFont(ofSize: 24)]
		navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
//		navigationController?.navigationBar.shadowImage = UIImage()
		
		// Navigation button
		// - Left button
		let backBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "NaviBack44"), style: .plain, target: self, action: #selector(backAction))
		backBtn.tintColor = UIHelper.defaultTint
		navigationItem.leftBarButtonItem = backBtn
		
		// Title
		title = "TODO"
		
		// Hide tool bar
		navigationController?.isToolbarHidden = true
		
		// Ttile field
		titleField.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(titleField)
		titleField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Padding.p5).isActive = true
		titleField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: Padding.p40).isActive = true
		titleField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -Padding.p40).isActive = true
		titleField.heightAnchor.constraint(equalToConstant: titleH).isActive = true
		
		// Title separator
		let titleSep = UIHelper.separator(withColor: #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1))
		titleSep.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(titleSep)
		titleSep.topAnchor.constraint(equalTo: titleField.bottomAnchor).isActive = true
		titleSep.leftAnchor.constraint(equalTo: titleField.leftAnchor, constant: -Padding.p20).isActive = true
		titleSep.rightAnchor.constraint(equalTo: titleField.rightAnchor, constant: Padding.p20).isActive = true
		titleSep.heightAnchor.constraint(equalToConstant: 1).isActive = true
		
        // Hint label
        let hintLabel = UILabel()
        hintLabel.font = UIFont.systemFont(ofSize: 12, weight: .light)
        hintLabel.textColor = #colorLiteral(red: 0.6642242074, green: 0.6642400622, blue: 0.6642315388, alpha: 1)
        hintLabel.text = "Pull down to add new task"
        hintLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hintLabel)
        hintLabel.topAnchor.constraint(equalTo: titleSep.bottomAnchor, constant: Padding.p5).isActive = true
        hintLabel.centerXAnchor.constraint(equalTo: titleSep.centerXAnchor).isActive = true
        
		// Summary view
		summaryView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(summaryView)
		summaryView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
		summaryView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
		summaryView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
		summaryView.heightAnchor.constraint(equalToConstant: summaryVH).isActive = true
		
		// Finish state
		finishState.translatesAutoresizingMaskIntoConstraints = false
		summaryView.addSubview(finishState)
		finishState.widthAnchor.constraint(equalToConstant: stateBlkH).isActive = true
		finishState.heightAnchor.constraint(equalToConstant: stateBlkH).isActive = true
		finishState.centerXAnchor.constraint(equalTo: summaryView.centerXAnchor).isActive = true
		finishState.centerYAnchor.constraint(equalTo: summaryView.centerYAnchor).isActive = true
		
		// Total state
		totalState.translatesAutoresizingMaskIntoConstraints = false
		summaryView.addSubview(totalState)
		totalState.widthAnchor.constraint(equalToConstant: stateBlkH).isActive = true
		totalState.heightAnchor.constraint(equalToConstant: stateBlkH).isActive = true
		totalState.centerYAnchor.constraint(equalTo: summaryView.centerYAnchor).isActive = true
		totalState.rightAnchor.constraint(equalTo: finishState.leftAnchor, constant: -Padding.p40).isActive = true
		
		// Progress state
		progressState.translatesAutoresizingMaskIntoConstraints = false
		summaryView.addSubview(progressState)
		progressState.widthAnchor.constraint(equalToConstant: stateBlkH).isActive = true
		progressState.heightAnchor.constraint(equalToConstant: stateBlkH).isActive = true
		progressState.centerYAnchor.constraint(equalTo: summaryView.centerYAnchor).isActive = true
		progressState.leftAnchor.constraint(equalTo: finishState.rightAnchor, constant: Padding.p40).isActive = true
		
		// List table
		listTable.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(listTable)
		listTable.topAnchor.constraint(equalTo: hintLabel.bottomAnchor, constant: Padding.p10).isActive = true
		listTable.leftAnchor.constraint(equalTo: view.leftAnchor, constant: Padding.p10).isActive = true
		listTable.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -Padding.p10).isActive = true
		listBottomCst = listTable.bottomAnchor.constraint(equalTo: summaryView.topAnchor)
		listBottomCst.isActive = true
	}
}

// MARK: - Delegates
// UITextField delegate
extension ListViewController: UITextFieldDelegate {
	func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
		// Hide done button
		navigationItem.rightBarButtonItem = nil
		return true
	}
}

// MARK: - UITableView delegate / data source
extension ListViewController: UITableViewDataSource, UITableViewDelegate {
	// Number of item
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return listItems.count
	}
	
	// Setup cell
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! ListTableCell
		// Assign cell closure
		cell.startEditing = startEditing
		cell.editingText = editintCelltext
		cell.endEditing = endEditing
		cell.refreshCell = refreshCell
		cell.addItem = addItem
		cell.taskCompleted = taskCompleted
		
		if indexPath.row < listItems.count {
			// Load data
			let data = listItems[indexPath.row]
			cell.feedData(data: data)
		}		
		return cell
	}
	
	// Customize swipe edit buttons
	func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
		// Customize edit button before edit begin
		for subview in tableView.subviews {
			// Found "UISwipeActionPullView"
			if (String(describing: subview).range(of: "UISwipeActionPullView") != nil) {
				// Find "UISwipeActionStandardButton"
				for view in subview.subviews {
					if (String(describing: view).range(of: "UISwipeActionStandardButton") != nil) {
						// Find and edit imageview
						for sbv in view.subviews {
							if (String(describing: sbv).range(of: "UIImageView") != nil) {
								if let imageView = sbv as? UIImageView {
									// Tweak: Delete button must be different size as other button to get different tint color
									if imageView.image?.size == #imageLiteral(resourceName: "Bin32").size {
										imageView.tintColor = #colorLiteral(red: 1, green: 0.4932718873, blue: 0.4739984274, alpha: 1)
									} 	
									else {
										imageView.tintColor = #colorLiteral(red: 1, green: 0.8039215686, blue: 0, alpha: 1)
									}
								}
							}
						}
					}
				}
			}
		}
	}
	
	// Swipe to right
	func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		
		let cell = listTable.cellForRow(at: indexPath) as? ListTableCell
		guard cell?.allowEdit() == true else { return nil }
		
		let action = UIContextualAction(style: .normal, title: "") { (action: UIContextualAction, view: UIView, success: (Bool) -> Void) in
			// Action here
			let reminderVC = ListDetailViewController()
			let navi = UINavigationController(rootViewController: reminderVC)
			self.present(navi, animated: true, completion: nil)
			success(true)
		}
		
		action.image = #imageLiteral(resourceName: "Edit44")
		action.backgroundColor = .white
		return UISwipeActionsConfiguration(actions: [action])
	}
	
	// Swipe to left
	func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		
		let cell = listTable.cellForRow(at: indexPath) as? ListTableCell
		guard cell?.allowEdit() == true else { return nil }
		
		let action = UIContextualAction(style: .normal, title: "") { (action: UIContextualAction, view: UIView, success: (Bool) -> Void) in
			self.listItems.remove(at: indexPath.row)
			self.listTable.reloadData()
			success(true)
		}
		action.image = #imageLiteral(resourceName: "Bin32")
		action.backgroundColor = .white
		return UISwipeActionsConfiguration(actions: [action])
	}
	
	// Should allow edit in cell
	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		if indexPath.row >= listItems.count {
			return false
		}
		return true
	}
}
