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
	// About pop over size
	private let aboutPopSize = CGSize(width: 320, height: 320)
	
	// - Variables
	// Header view height constraint
	private var headerHCst = NSLayoutConstraint()
	// Function view height constraint
	private var funcViewHCst = NSLayoutConstraint()
	// Search table bottom constraint
	private var sTBCst = NSLayoutConstraint()
	// Resume scroll offset (search)
	private var resumeOffset = CGPoint.zero
	// Is searching flag
	private var isSearching = false
	
	// View model
	private let viewModel = MemoViewModel()
	
	
	// MARK: - Views
	// Loading view
	private var loadingView: UIView?
	
	// Logo
	private var logo: UIImageView?
	
	// Header view
	private lazy var headerView = HeaderView()
	
	// Home table view
	private lazy var homeTable: UITableView = {
		let table = UITableView(frame: .zero, style: .plain)
		table.keyboardDismissMode = .onDrag
		table.separatorStyle = .none
		table.rowHeight = 140
		table.contentInset = UIEdgeInsets(top: headerH, left: 0, bottom: 0, right: 0)
		// Prevent tableview adjust inset automattically
		table.contentInsetAdjustmentBehavior = .never
		table.showsHorizontalScrollIndicator = false
		return table
	}()
	
	// Search table
	private lazy var searchTable: UITableView = {
		let st = UITableView(frame: .zero, style: .plain)
		st.keyboardDismissMode = .interactive
		st.rowHeight = 60
		return st
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

// MARK: - Override functions
extension HomeViewController {
	// MARK: - Override functions
	override func viewDidLoad() {
		super.viewDidLoad()
		startLoading()
		
		// Hide search table
		searchTable.isHidden = true
		
		// Setup view model
		viewModel.fetchingData = isFetchingData
		viewModel.reloadData = reloadTable
		viewModel.editMemo = editMemo
		
		// Notification observer
		// Re-fetch data
		NotificationCenter.default.addObserver(self, selector: #selector(reFetchData), name: .reFetchData, object: nil)
		// Add new memo
		NotificationCenter.default.addObserver(self, selector: #selector(addNewMemo(_:)), name: .addNewMemo, object: nil)
		// Refresh Table
		NotificationCenter.default.addObserver(self, selector: #selector(reloadTable), name: .reloadHomeList, object: nil)
		// Show keyboard
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardAction(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
		// Hide keyboard
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardAction(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
		
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
//		viewModel.cancelFetch()
	}
}

// MARK: - Private functions
extension HomeViewController {
	// End fetch data
	private func isFetchingData(isFetching: Bool) {
		if isFetching {
			animateLoading()
		}
	}
	
	// Edit memo
	private func editMemo(memo: Memo) {
		let type: MemoType = MemoType(rawValue: memo.type.rawValue)!
		switch type {
		case .attach:
			guard let attchMemo = memo as? AttachmentMemo else { return }
			navigationController?.pushViewController(MemoViewController(memo: attchMemo), animated: true)
			
		case .todo:
			guard let todoMemo = memo as? ListMemo else { return }
			navigationController?.pushViewController(ListViewController(memo: todoMemo), animated: true)
			
		default:
			()
		}
	}
	
	// End search
	private func endSearch() {
		isSearching = false
		
		// Empty search result
		viewModel.resetSearchResult()
		searchTable.reloadData()
		
		// Show home table
		homeTable.isHidden = false
		
		// Hide result table
		searchTable.isHidden = true
		
		// Empty search bar
		headerView.searchbar.text = ""
		
		DispatchQueue.main.async {
			// Hide cancel button
			self.headerView.searchbar.setShowsCancelButton(false, animated: true)
			// Resume offset
			self.homeTable.setContentOffset(self.resumeOffset, animated: true)
			// Enable scroll
			self.homeTable.isScrollEnabled = true
		}
	}
	
	// Start loading
	private func startLoading() {
		loadingView = UIView(frame: UIScreen.main.bounds)
		loadingView?.backgroundColor = .white
		
		// Logo
		logo = UIImageView(image: #imageLiteral(resourceName: "Memoit"))
		logo?.contentMode = .scaleAspectFit
		
		guard let loadingView = self.loadingView, 
			let logo = self.logo else { return }
		loadingView.addSubview(logo)
		logo.translatesAutoresizingMaskIntoConstraints = false
		logo.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor).isActive = true
		logo.centerYAnchor.constraint(equalTo: loadingView.centerYAnchor).isActive = true
		logo.widthAnchor.constraint(equalTo: loadingView.widthAnchor, multiplier: 0.5).isActive = true
		logo.heightAnchor.constraint(equalTo: loadingView.widthAnchor).isActive = true
		
		view.addSubview(loadingView)
	}
	
	// Animate loading
	private func animateLoading() {
		guard let loadingView = self.loadingView, 
			let logo = self.logo else { return } 
		UIView.animateKeyframes(withDuration: 1.0, delay: 0, 
								options: .calculationModeLinear, 
								animations: { 
									UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.1, animations: { logo.alpha = 0.5 })
									UIView.addKeyframe(withRelativeStartTime: 0.1, relativeDuration: 0.1, animations: { logo.alpha = 1.0 })
									UIView.addKeyframe(withRelativeStartTime: 0.2, relativeDuration: 0.1, animations: { logo.alpha = 0.5 })
									UIView.addKeyframe(withRelativeStartTime: 0.3, relativeDuration: 0.1, animations: { logo.alpha = 1.0 })
									UIView.addKeyframe(withRelativeStartTime: 0.4, relativeDuration: 0.1, animations: { logo.alpha = 0.5 })
									UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.1, animations: { logo.alpha = 1.0 })
		}, completion: { _ in
			UIView.animate(withDuration: 1.0, animations: { logo.alpha = 1.0 }, 
						   completion: { _ in  loadingView.removeFromSuperview()})
		})
	}
}

// MARK: - Actions
extension HomeViewController {
	// Refetch data
	@objc private func reFetchData() {
		DispatchQueue.main.async {
			self.viewModel.fetchData()
		}
	}
	
	// Cancel option aciton
	@objc private func cancelOptionAction() {
		functionView.resetOption(animated: true)
	}
	
	// Reload home table
	@objc private func reloadTable() {
		// Sort memo by modified time
		viewModel.sortData()
		// Must have this line, or tableview not scroll to the top after reload
		homeTable.setContentOffset(CGPoint(x: 0, y: -headerH), animated: false)
		homeTable.reloadData()
		// Play the magic here
		homeTable.layoutIfNeeded()
		homeTable.setContentOffset(CGPoint(x: 0, y: -headerH), animated: false)
	}
	
	// Show / hide keyboard
	@objc private func keyboardAction(_ notification: Notification) {
		// User info
		guard let userinfo = notification.userInfo else { return }
		
		// System animation duration
		guard let duraation: TimeInterval = userinfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
		
		if notification.name == UIResponder.keyboardWillShowNotification {
			// Show keyboard
			guard let rectValue = userinfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
			// Keyboard height
			let kbH: CGFloat = rectValue.cgRectValue.height
			sTBCst.constant = -kbH + self.view.safeAreaInsets.bottom
		}
		else {
			// Hide keyboard
			sTBCst.constant = 0
			endSearch()
		}
		
		UIView.animate(withDuration: duraation) { 
			self.view.layoutIfNeeded()
		}
	}
	
	// Add new memo
	@objc private func addNewMemo(_ notification: Notification) {
		guard let userInfo = notification.userInfo else { return }
		if let memo = userInfo["Memo"] as? Memo {
			viewModel.addMemoToList(memo: memo)
		}
	}
}

// MARK: - Delegates
// MARK: - UITableView data source / delegate / prefetch
extension HomeViewController: UITableViewDelegate, UITableViewDataSource, UITableViewDataSourcePrefetching {
	// Number of rows
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if tableView === homeTable {
			return viewModel.numberOfItems()
		}
		else if tableView === searchTable {
			return viewModel.numberOfSearchResult()
		}
		return 0
	}
	
	// Setup cell
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if tableView === homeTable {
			return viewModel.updateCell(tableView, indexPath)
		}
		else if tableView === searchTable {
			return viewModel.updateSearchCell(tableView, indexPath)
		}
		return UITableViewCell()
	}
	
	// Select cell
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if tableView === homeTable {
			viewModel.editMemoAt(indexPath)
		}
		else if tableView === searchTable {
			viewModel.editFromSearch(indexPath)
			view.endEditing(true)
			
			DispatchQueue.main.async {
				self.endSearch()
			}
		}
	}
	
	// Should allow edit in cell
	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		if tableView == homeTable {
			return true
		}
		return false
	}
	
	// swipe to left
	func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		if tableView == homeTable {
			// Detele action
			let action = UIContextualAction(style: .normal, title: "") { 
				(action, _, success) in
				self.viewModel.deleteMemo(indexPath)
				success(true)
			}
			action.image = #imageLiteral(resourceName: "Bin44")
			action.backgroundColor = .white
			return UISwipeActionsConfiguration(actions: [action])
		}
		return nil
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
									imageView.tintColor = #colorLiteral(red: 1, green: 0.4932718873, blue: 0.4739984274, alpha: 1)
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
}

// UISearchView delegate
extension HomeViewController: UISearchBarDelegate {
	
	func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
		// Show edit button
		searchBar.setShowsCancelButton(true, animated: true)
		
		// Set flag
		isSearching = true
		
		// Disable home table scroll
		homeTable.isScrollEnabled = false
		
		// Show result table here
		searchTable.isHidden = false
		
		// Hide home table
		homeTable.isHidden = true
		
		// Set resume offset
		resumeOffset = homeTable.contentOffset
		
		DispatchQueue.main.async {
			// Home table scroll up
			let targetOffset  = self.headerView.frame.height
			if self.homeTable.contentOffset.y < targetOffset {
				let offsetPoint = CGPoint(x: 0, y: targetOffset)
				self.homeTable.setContentOffset(offsetPoint, animated: true)
			}
		}
		return true 
	}
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		viewModel.resetSearchResult()
		if !searchText.isEmpty {
			if viewModel.canSearch() {
				 viewModel.searchMemo(text: searchText)
			}
		}
		searchTable.reloadData()
	}
	
	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		// Hide keyboard
		searchBar.resignFirstResponder()
	}
}

// MARK: - Function view delegate
extension HomeViewController: FunctionViewDelegate {
	func menuAction() {
		print("Menu action")
		
		let navi = UINavigationController(rootViewController: SettingViewController())
		present(navi, animated: true, completion: nil)
	}
	
	func moreAction() {
		print("More action")
		
		let aboutVC = AboutViewController()
		aboutVC.modalPresentationStyle = .popover
		
		// Pop over
		if let aboutPopOver = aboutVC.popoverPresentationController {
			aboutPopOver.delegate = self
			aboutPopOver.permittedArrowDirections = .init(rawValue: 0) // 0 = No arrow
			aboutPopOver.sourceView = self.view
			aboutPopOver.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
			aboutVC.preferredContentSize = aboutPopSize
		}
		present(aboutVC, animated: true, completion: nil)
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
		navigationController?.pushViewController(MemoViewController(memo: nil), animated: true)
		functionView.resetOption(animated: false)
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
	}
}

// MARK: - UIPopoverPresentationControllerDelegate
extension HomeViewController: UIPopoverPresentationControllerDelegate {
	func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
		return true
	}
	
	func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
		return .none
	}
}

// MARK: - Setup UI
extension HomeViewController {
	
	override func loadView() {
		super.loadView()
		
		view.backgroundColor = .white
		
		// Function view
		functionView.delegate = self
		functionView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(functionView)
		functionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
		functionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
		functionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
		funcViewHCst = functionView.heightAnchor.constraint(equalToConstant: functionView.originalH)
		funcViewHCst.isActive = true
		
		// Table view
		homeTable.delegate = self
		homeTable.dataSource = self
		homeTable.prefetchDataSource = self
		homeTable.register(HomeAttachCell.self, forCellReuseIdentifier: viewModel.attachID)
		homeTable.register(HomeTodoCell.self, forCellReuseIdentifier: viewModel.todoID)
		homeTable.register(HomeVoiceCell.self, forCellReuseIdentifier: viewModel.voiceID)
		view.insertSubview(homeTable, belowSubview: functionView)
		homeTable.translatesAutoresizingMaskIntoConstraints = false
		homeTable.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
		homeTable.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
		homeTable.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
		homeTable.bottomAnchor.constraint(equalTo: functionView.topAnchor).isActive = true
		
		// Search table
		searchTable.delegate = self
		searchTable.dataSource = self
		searchTable.register(SearchViewCell.self, forCellReuseIdentifier: viewModel.searchID)
		view.insertSubview(searchTable, aboveSubview: homeTable)
		searchTable.translatesAutoresizingMaskIntoConstraints = false
		searchTable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: UIHelper.defaultH).isActive = true
		searchTable.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
		searchTable.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
		sTBCst = searchTable.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
		sTBCst.isActive = true
		
		
		// Table header view
		headerView.searchbar.delegate = self
		headerView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(headerView)
		headerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
		headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
		headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
		headerHCst = headerView.heightAnchor.constraint(equalToConstant: headerH)
		headerHCst.isActive = true
		
		
		// Option overlay
		optionOverlay.alpha = 0
		optionOverlay.isHidden = true
		optionOverlay.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(optionOverlay)
		optionOverlay.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
		optionOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
		optionOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
		optionOverlay.bottomAnchor.constraint(equalTo: functionView.topAnchor).isActive = true
	}
}
