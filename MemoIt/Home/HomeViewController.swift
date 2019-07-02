//
//  HomeViewController.swift
//  MemoIt
//
//  Created by MICA17 on 2/6/19.
//  Copyright © 2019 MC2. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
	// MARK: - Properties
	// - Constants
	// Header height
	private let headerH: CGFloat = 240
	// Header minimum stretch height
	private let headerHmin: CGFloat = 90
	// Header maximum stretch height
	private let headerHmax: CGFloat = UIScreen.main.bounds.height
	
	// - Variables
	// Header view height constraint
	private var headerHCst = NSLayoutConstraint()
	// Function view height constraint
	private var funcViewHCst = NSLayoutConstraint()
	// Resume scroll offset (search)
	private var resumeOffset = CGPoint.zero
	
	
	
	// View model
	let viewModel = MemoViewModel()
	
	// MARK: - Views
	// Header view
	private lazy var headerView = HeaderView()
	
	// Home table view
	private lazy var homeTable: UITableView = {
		let table = UITableView(frame: .zero, style: .plain)
		table.keyboardDismissMode = .onDrag
		table.separatorStyle = .none
		table.rowHeight = 160
		table.contentInset = UIEdgeInsets(top: headerH, left: 0, bottom: 0, right: 0)
		table.showsHorizontalScrollIndicator = false
		table.delegate = self
		table.dataSource = self
		table.prefetchDataSource = self
		table.register(HomeAttachCell.self, forCellReuseIdentifier: viewModel.attachID)
		table.register(HomeTodoCell.self, forCellReuseIdentifier: viewModel.todoID)
		table.register(HomeVoiceCell.self, forCellReuseIdentifier: viewModel.voiceID)
		return table
	}()
	
	// Function view
	private lazy var functionView = FunctionView()
	
	// Option overlay
	private lazy var optionOverlay: UIView = {
		let v = UIView()
		v.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3)
		
		// Gesture
		let tap = UITapGestureRecognizer(target: self, action: #selector(cancelOptionAction))
		tap.numberOfTapsRequired = 1
		tap.numberOfTouchesRequired = 1
		v.addGestureRecognizer(tap)
		return v
	}()
	
}


// MARK: - Private functions
extension HomeViewController {
	// Reload table
	private func reloadTable() {
		homeTable.reloadData()
	}
}

// MARK: - Actions
extension HomeViewController {
	// Cancel option aciton
	@objc private func cancelOptionAction() {
		functionView.resetOption(animated: true)
	}
	
	// Reload
	@objc private func refreshTable() {
		viewModel.fetchData()
	}
}

// MARK: - Override functions
extension HomeViewController {
	// MARK: - Override functions
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Setup view model
		viewModel.reloadData = reloadTable
		
		// Notification observer
		NotificationCenter.default.addObserver(self, selector: #selector(refreshTable), name: .newItemHomeTable, object: nil)
		
		// Register cells
		homeTable.register(HomeAttachCell.self, forCellReuseIdentifier: viewModel.attachID)
		homeTable.register(HomeTodoCell.self, forCellReuseIdentifier: viewModel.todoID)
		homeTable.register(HomeVoiceCell.self, forCellReuseIdentifier: viewModel.voiceID)
		
		// Scroll to top
//		let index = IndexPath(row: 0, section: 0)
//		homeTable.scrollToRow(at: index, at: .middle, animated: false)
		
		// Fetch data
		viewModel.fetchData()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		// Hide navigation bar
		navigationController?.isNavigationBarHidden = true
		
		// Hide tool bar
		navigationController?.isToolbarHidden = true
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		viewModel.cancelFetch()
	}
	
	override func loadView() {
		super.loadView()
		
		view.backgroundColor = .white
		
		// Function view
		functionView.delegate = self
		functionView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(functionView)
		functionView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
		functionView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
		functionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
		funcViewHCst = functionView.heightAnchor.constraint(equalToConstant: functionView.originalH)
		funcViewHCst.isActive = true
		
		// Table view
		homeTable.translatesAutoresizingMaskIntoConstraints = false
		view.insertSubview(homeTable, belowSubview: functionView)
		homeTable.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
		homeTable.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
		homeTable.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
		homeTable.bottomAnchor.constraint(equalTo: functionView.topAnchor).isActive = true
		
		// Table header view
		headerView.searchbar.delegate = self
		headerView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(headerView)
		headerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
		headerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
		headerView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
		headerHCst = headerView.heightAnchor.constraint(equalToConstant: headerH)
		headerHCst.isActive = true
		
		// Option overlay
		optionOverlay.alpha = 0
		optionOverlay.isHidden = true
		optionOverlay.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(optionOverlay)
		optionOverlay.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
		optionOverlay.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
		optionOverlay.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
		optionOverlay.bottomAnchor.constraint(equalTo: functionView.topAnchor).isActive = true
		
	}
}



// MARK: - Delegates
// MARK: - UITableView data source / delegate / prefetch
extension HomeViewController: UITableViewDelegate, UITableViewDataSource, UITableViewDataSourcePrefetching {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModel.memoList.count
		//		return homeItems.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cellID = viewModel.cellId(atIndex: indexPath)
		let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! HomeCell
		viewModel.updateCell(cell, indexPath)
		return cell
	}
	
	
	// Scroll view delegate
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		// Update header view size
		let offsetY = scrollView.contentOffset.y
		let y = headerH - (offsetY + headerH)
		let height = min(max(y, headerHmin), headerHmax)
		headerHCst.constant = height
		
		// Update search bar container alpha
		let statusBarH = UIApplication.shared.statusBarFrame.height
		let fullHeaderH = statusBarH + headerH
		let delta = height - headerHmin
		let alpha = 1 - (delta / (fullHeaderH - headerHmin))
		headerView.updateAlpha(alpha: alpha)
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


// UISearchView delegate
extension HomeViewController: UISearchBarDelegate {
	
	func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
		// Show edit button
		searchBar.showsCancelButton = true
		
		// Disable home table scroll
		homeTable.isScrollEnabled = false
		
		// Show result table here
		// FIXME: show result table
		
		// Set resume offset
		resumeOffset = homeTable.contentOffset
		
		// Home table scroll up
		let targetOffset  = headerView.frame.height
		if homeTable.contentOffset.y < targetOffset {
			let offsetPoint = CGPoint(x: 0, y: targetOffset)
			homeTable.setContentOffset(offsetPoint, animated: true)
		}
		
		return true
	}
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		
	}
	
	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		// Hide cancel button
		searchBar.showsCancelButton = false
		// Hide keyboard
		searchBar.resignFirstResponder()
		// Resume offset
		homeTable.setContentOffset(resumeOffset, animated: true)
		// Enable scroll
		homeTable.isScrollEnabled = true
		// Empty search bar
		headerView.searchbar.text = ""
		
		
		// Hide result table
		// FIXME: hide result table
	}
}

// MARK: - Function view delegate
extension HomeViewController: FunctionViewDelegate {
	func menuAction() {
		print("Menu action")
	}
	
	func moreAction() {
		print("More action")
	}
	
	func showOption() {
		funcViewHCst.constant = functionView.originalH + functionView.expandH
		functionView.showOption()
		optionOverlay.alpha = 0
		optionOverlay.isHidden = false
		UIView.animate(withDuration: 0.2, animations: {
			self.optionOverlay.alpha = 1
			self.functionView.showOptionTransition()
			self.view.layoutIfNeeded()
			
		}) { (finished) in
			self.functionView.showCompleted()
		}
	}
	
	func hideOption(animated: Bool) {
		optionOverlay.alpha = 1
		funcViewHCst.constant = functionView.originalH
		functionView.hideOption()
		
		if animated {
			UIView.animate(withDuration: 0.2, animations: {
				self.optionOverlay.alpha = 0
				self.functionView.hideOptionTransition()
				self.view.layoutIfNeeded()
			}) { (finished) in
				self.optionOverlay.isHidden = true
				self.functionView.hideCompleted()
			}
		}
		else {
			optionOverlay.alpha = 0
			functionView.hideOptionTransition()
			optionOverlay.isHidden = true
			functionView.hideCompleted()
		}
	}
	
	func addMemo() {
		print("Add memo")
		let attachVC = MemoViewController()
//		presentVC(vc: attachVC)
	}
	
	func addVoice() {
		print("Add voice")
		navigationController?.pushViewController(VoiceViewController(type: .voiceMemo), animated: true)
		functionView.resetOption(animated: false)
	}
	
	func addTodoList() {
		print("Add todo")
		navigationController?.pushViewController(ListViewController(memo: nil), animated: true)
		functionView.resetOption(animated: false)
//		presentVC(vc: todoVC)
	}
	
	
}
