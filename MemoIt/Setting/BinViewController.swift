//
//  BinViewController.swift
//  MemoIt
//
//  Created by mk mk on 26/8/19.
//  Copyright © 2019 MC2. All rights reserved.
//

import UIKit

class BinViewController: UIViewController {
	// MARK: - Properties
	// - Constants
	private let hintViewH: CGFloat = 60
	
	// - Variables
	// View model
	private let viewModel = BinViewModel()
    
	
	// - Views
	// Search table
	private lazy var searchTable: UITableView = {
		let table = UITableView(frame: .zero, style: .plain)
		table.separatorStyle = .none
		table.rowHeight = 140
		table.showsHorizontalScrollIndicator = false
		return table
	}()
	
	// Empty note label
	private lazy var emptyLabel: UILabel = {
		let label = UILabel()
		label.textAlignment = .center
		label.textColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
		label.font = UIFont.preferredFont(forTextStyle: .title1)
		label.text = "Empty Bin"
		return label
	}()
}

// MARK: - Override function  
extension BinViewController {
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Assign view model closure
		viewModel.reloadData = reloadData
		
		// Fetch data
		viewModel.fetchData()
	}
}

// MARK: - Private function
extension BinViewController {
	// Reload data
	private func reloadData() {
		searchTable.reloadData()
		if viewModel.numberOfItems() < 1 {
			searchTable.backgroundView = emptyLabel
		}
		else {
			searchTable.backgroundView = nil
		}
	}
	
	// Hint label
	private func hintLabel() -> UILabel {
		let lb = UILabel()
		lb.textAlignment = .center
		lb.textColor = #colorLiteral(red: 0.4756349325, green: 0.4756467342, blue: 0.4756404161, alpha: 1)
		lb.font = UIFont.systemFont(ofSize: 12, weight: .regular)
		return lb
	}
}

// MARK: - Action
extension BinViewController {
	// Back action
	@objc private func backAction() {
		navigationController?.popViewController(animated: true)
	}
}


// MARK: - Delegate
extension BinViewController: UITableViewDelegate, UITableViewDataSource, UITableViewDataSourcePrefetching {
	// Number of items
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModel.numberOfItems()
	}
	
	// Setup cell
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		return viewModel.updateCell(tableView, indexPath)
	}
	
	// Can edit cell
	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return true
	}
	
	// Swift to left
	func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		// Delete action
		let action = UIContextualAction(style: .normal, title: "") { 
			(action, _, success) in
			DispatchQueue.main.async {
				let alert = UIAlertController(title: "Delete file?", message: "Data will be permanently delete, and not recoverable.", preferredStyle: .alert)
				alert.addAction(UIAlertAction(title: "Cancle", style: .cancel, handler: nil))
				alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
					self.viewModel.deleteData(indexPath)
					
				}))
				self.present(alert, animated: true, completion: nil)
			}
			success(true)
		}
		action.image = #imageLiteral(resourceName: "Bin44")
		action.backgroundColor = .white
		return UISwipeActionsConfiguration(actions: [action])
	}
	
	// Swift to right
	func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		// Restore action
		let action = UIContextualAction(style: .normal, title: "") { 
			(action, _, success) in
			self.viewModel.restoreData(indexPath)
			NotificationCenter.default.post(name: .reFetchData, object: nil)
			success(true)
		}
		action.image = #imageLiteral(resourceName: "UndoBtn")
		action.backgroundColor = .white
		return UISwipeActionsConfiguration(actions: [action])
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
									if let image = imageView.image {
										if let data = image.pngData(),
											let binData = #imageLiteral(resourceName: "Bin44").pngData() {
											if data == binData {
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
		}
	}
	
	// Prefetch
	func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
		viewModel.prefetchData(indexPaths)
	}
	
	// Cancel prefetch
	func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
		viewModel.cancelPrefetch(indexPaths)
	}
}

// MARK: -  Setup UI
extension BinViewController {
	override func loadView() {
		super.loadView()
		view.backgroundColor = .white
		
		// Navigation bar
		// Title 
		navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1),
																   NSAttributedString.Key.font: UIFont.systemFont(ofSize: 24)]
		title = "Bin"
		
		// Left button
		let leftBtn = UIButton(type: .custom)
		leftBtn.setImage(#imageLiteral(resourceName: "NaviBack44"), for: .normal)
		leftBtn.addTarget(self, action: #selector(backAction), for: .touchUpInside)
		navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftBtn)
		
		// Hint view
		let hintView = UIView()
		hintView.isUserInteractionEnabled = false		
		view.addSubview(hintView)
		hintView.translatesAutoresizingMaskIntoConstraints = false
		hintView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
		hintView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
		hintView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
		hintView.heightAnchor.constraint(equalToConstant: hintViewH).isActive = true
		
		// Swipe left label
		let swipeL = hintLabel()
		swipeL.text = "Swipe <- LEFT to delete"
		hintView.addSubview(swipeL)
		swipeL.translatesAutoresizingMaskIntoConstraints = false
		swipeL.bottomAnchor.constraint(equalTo: hintView.centerYAnchor, constant: -Padding.p2).isActive = true
		swipeL.centerXAnchor.constraint(equalTo: hintView.centerXAnchor).isActive = true
		
		// Swipe rigth label
		let swipeR = hintLabel()
		swipeR.text = "Swipe RIGHT -> to restore"
		hintView.addSubview(swipeR)
		swipeR.translatesAutoresizingMaskIntoConstraints = false
		swipeR.topAnchor.constraint(equalTo: hintView.centerYAnchor, constant: Padding.p2).isActive = true
		swipeR.centerXAnchor.constraint(equalTo: hintView.centerXAnchor).isActive = true
		
		// Search table
		searchTable.delegate = self
		searchTable.dataSource = self
		searchTable.register(HomeAttachCell.self, forCellReuseIdentifier: viewModel.attachID)
		searchTable.register(HomeTodoCell.self, forCellReuseIdentifier: viewModel.todoID)
		searchTable.register(HomeVoiceCell.self, forCellReuseIdentifier: viewModel.voiceID)
		view.addSubview(searchTable)
		searchTable.translatesAutoresizingMaskIntoConstraints = false
		searchTable.topAnchor.constraint(equalTo: hintView.bottomAnchor).isActive = true
		searchTable.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
		searchTable.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
		searchTable.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
	}
}
