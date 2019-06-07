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
	// Cell ID
	private let cellId = "HomeCell"
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
	
	private var homeItems = [Any]()
	
	// Resume scroll offset (search)
	private var resumeOffset = CGPoint.zero
	
	
	// MARK: - Views
	// Header view
	private lazy var headerView = HeaderView()
	
	// Home table view
	private lazy var homeTable: UITableView = {
		let table = UITableView(frame: .zero, style: .plain)
		table.keyboardDismissMode = .onDrag
		table.separatorStyle = .none
		table.contentInset = UIEdgeInsets(top: headerH, left: 0, bottom: 0, right: 0)
		table.showsHorizontalScrollIndicator = false
		table.delegate = self
		table.dataSource = self
		table.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
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
	
}

// MARK: - Actions
extension HomeViewController {
	// Cancel option aciton
	@objc private func cancelOptionAction() {
		functionView.resetOption(animated: true)
	}
	
}

// MARK: - Override functions
extension HomeViewController {
	
	// MARK: - Override functions
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Scroll to top
		let index = IndexPath(row: 0, section: 0)
		homeTable.scrollToRow(at: index, at: .middle, animated: false)
	}
	
	override func loadView() {
		super.loadView()
		
		view.backgroundColor = .white
		
		// Hide navigation bar
		navigationController?.isNavigationBarHidden = true
		
		// Hide tool bar
		navigationController?.isToolbarHidden = true
		
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
// MARK: - UITableView data source / delegate
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 20
		//		return homeItems.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
		cell.textLabel?.text = String(describing: indexPath.row)
		return cell
	}
	
	
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
	}
	
	func addVoice() {
		print("Add voice")
	}
	
	func addTodoList() {
		print("Add todo")
	}
	
	
}
