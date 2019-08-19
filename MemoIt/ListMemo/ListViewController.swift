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
	private let CellId = "ListCell"
	// Title field height
	private let titleH: CGFloat = 44
	// Summary view height
	private let summaryVH: CGFloat = 72
	// Add task view height
	private let addTaskH: CGFloat = 80
	
	// - Data collection
    // View model
	private var viewModel = ListViewModel()
	// List memo object reference
	private var memoData: ListMemo?
    
	// - Variables
	// Add task view bottom constraint
	private var addTaskBtmCst = NSLayoutConstraint()
	
	// Should save flag
	private var shouldSave: Bool = false
	// Is editing mode flag
	private var isEditingMode: Bool = false
		

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
    
	// - List table
	private lazy var listTable: UITableView = {
		let table = UITableView(frame: CGRect.zero, style: .plain)
		table.backgroundColor = .clear
		table.allowsSelection = false
		table.allowsMultipleSelection = false
		table.isMultipleTouchEnabled = false
		table.separatorStyle = .none
		table.rowHeight = UITableView.automaticDimension
		table.keyboardDismissMode = .interactive
		table.dataSource = self
		table.delegate = self
		table.register(ListTableCell.self, forCellReuseIdentifier: ListViewModel.listCellID)
		return table
	}()
	
	// Add task view
	private lazy var addTaskView = AddTaskView()
	
	
	// MARK: - Custom init
	init(memo: ListMemo?) {
		super.init(nibName: nil, bundle: nil)
		
		// Assign closure function
		viewModel.reloadTable = reloadTable
		viewModel.reloadCell = reloadCell
		
		if let listMemo = memo {
			// View model load data
			viewModel.loadData(memo: listMemo)
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError()
	}
}

// MARK: - Override functions
extension ListViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Assign view model closures
        viewModel.reloadTable = reloadTable
		viewModel.reloadCell = reloadCell
		
        // Keyboard show / hide notification
        // - Keyboard will show
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardAction(_:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        // - Keyboard will hide
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardAction(_:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}

// MARK: - Private function
extension ListViewController {
	
}

// MARK: - Closure functions
extension ListViewController {    
    // Reload table
    private func reloadTable() {
        listTable.reloadData()
    }
    
	// Reload cell
	private func reloadCell(_ indexpath: IndexPath) {
		listTable.reloadRows(at: [indexpath], with: .automatic)
	}
	
	// Add new task
	private func addNewTask(task: ListItemModel) {
		viewModel.addNewTask(task)
	}
}

// MARK: - Actions
extension ListViewController {
	// Back button action
	@objc private func backAction() {
		// Hide keyboard
		view.endEditing(true)
		// Save function
		viewModel.save(title: titleField.text)
		// Dismiss VC
		navigationController?.popViewController(animated: true)
	}
    
	// MARK: - Keyboard Action
	@objc private func keyboardAction(_ notification: Notification) {
		print("kb action")
		// User info
		guard let userInfo = notification.userInfo else { return }
		// System keyboard animation duration
		guard let duration: TimeInterval = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
		
		if notification.name == UIResponder.keyboardWillShowNotification {
			// Show keyboard
			guard let rectValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
			// Keyboard height
			let kbH: CGFloat = rectValue.cgRectValue.height
			// Update constraint
			addTaskBtmCst.constant = -kbH + self.view.safeAreaInsets.bottom
			addTaskView.edit()
		}
		else {
			// Hide keyboard
			addTaskBtmCst.constant = 0
			addTaskView.idle()
		}
		
		UIView.animate(withDuration: duration) { 
			self.view.layoutIfNeeded()
		}
	}
}

// MARK: - Delegates
// MARK: - UITextField delegate
extension ListViewController: UITextFieldDelegate {
	func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
		print("should beging")
		if textField === titleField {
			self.addTaskView.isHidden = true
		}
		return true
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
	
	func textFieldDidEndEditing(_ textField: UITextField) {
		print("did end")
		if textField === titleField {
			self.addTaskView.isHidden = false
		}
	}
}

// MARK: - UITableView delegate / data source
extension ListViewController: UITableViewDataSource, UITableViewDelegate {
	// Number of item
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModel.numberOfItems()
	}
	
	// Setup cell
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		return viewModel.updateCell(tableView, indexPath)
	}
	
	// Cell height
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableView.automaticDimension
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
										imageView.tintColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
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
		// Done action
		if viewModel.hasComplete(indexpath: indexPath) == false {
			let cell = listTable.cellForRow(at: indexPath) 
			if let listCell = cell as? ListTableCell {
				let action = UIContextualAction(style: .normal, title: "") { (action: UIContextualAction, view: UIView, success: (Bool) -> Void) in
					// Action here
					self.viewModel.updateCompleteTask(listCell, true)
					success(true)
				}
				action.image = #imageLiteral(resourceName: "Tick44")
				action.backgroundColor = .white
				return UISwipeActionsConfiguration(actions: [action])
			}
		}
		return nil
	}
	
	// Swipe to left
	func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		// Delete action
		let cell = listTable.cellForRow(at: indexPath)
		if let _ = cell as? ListTableCell {
			//		guard cell?.allowEdit() == true else { return nil }
			
			let action = UIContextualAction(style: .normal, title: "") { 
				(action: UIContextualAction, view: UIView, success: (Bool) -> Void) in
				self.viewModel.removeTask(indexPath)
				success(true)
			}
			action.image = #imageLiteral(resourceName: "Bin32")
			action.backgroundColor = .white
			return UISwipeActionsConfiguration(actions: [action])			
		}
		return nil
	}
	
	// Should allow edit in cell
	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return true
	}
}

// MARK: - Setup UI
extension ListViewController {
    
    override func loadView() {
        super.loadView()
        
        // Background color
        view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        // Navigation bar
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1),
                                                                   NSAttributedString.Key.font: UIFont.systemFont(ofSize: 24)]
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
		navigationController?.navigationBar.shadowImage = UIImage()
        
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
		titleField.delegate = self
        view.addSubview(titleField)
		titleField.translatesAutoresizingMaskIntoConstraints = false
        titleField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Padding.p20).isActive = true
        titleField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Padding.p40).isActive = true
        titleField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Padding.p20).isActive = true
        titleField.heightAnchor.constraint(equalToConstant: titleH).isActive = true
        
		// Separator
		let sep = UIView()
		sep.backgroundColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 0.8)
		sep.isUserInteractionEnabled = false
		view.addSubview(sep)
		sep.translatesAutoresizingMaskIntoConstraints = false
		sep.topAnchor.constraint(equalTo: titleField.bottomAnchor).isActive = true
		sep.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Padding.p20).isActive = true
		sep.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
		sep.heightAnchor.constraint(equalToConstant: 1).isActive = true

		// Add task view
		addTaskView.newTask = addNewTask
		view.addSubview(addTaskView)
		addTaskView.translatesAutoresizingMaskIntoConstraints = false
		addTaskView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
		addTaskView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
		addTaskBtmCst = addTaskView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
		addTaskBtmCst.isActive = true
        
        // List table
//		listTable.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
        view.addSubview(listTable)
		listTable.translatesAutoresizingMaskIntoConstraints = false
        listTable.topAnchor.constraint(equalTo: sep.bottomAnchor, constant: Padding.p20).isActive = true
        listTable.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Padding.p10).isActive = true
        listTable.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Padding.p10).isActive = true
		listTable.bottomAnchor.constraint(equalTo: addTaskView.topAnchor).isActive = true
    }
}
