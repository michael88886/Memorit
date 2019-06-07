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
	
	private var homeItems = [Any]()
	
	// Resume scroll offset (search)
	private var resumeOffset = CGPoint.zero
	
	
	// MARK: - Views
	
	private lazy var headerView = HeaderView()
	
	private lazy var homeTable: UITableView = {
		let table = UITableView(frame: .zero, style: .plain)
		table.keyboardDismissMode = .onDrag
		
//		table.backgroundColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
		table.separatorStyle = .none
		table.contentInset = UIEdgeInsets(top: headerH, left: 0, bottom: 0, right: 0)
		table.showsHorizontalScrollIndicator = false
		table.delegate = self
		table.dataSource = self
		table.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
		return table
	}()
	
	
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
		
		// Hide navigation bar
		navigationController?.isNavigationBarHidden = true
		
		// Hide tool bar
		navigationController?.isToolbarHidden = true
		
		
		// Table view
		homeTable.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(homeTable)
		homeTable.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
		homeTable.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
		homeTable.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
		homeTable.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
		
		// Table header view
		headerView.searchbar.delegate = self
		headerView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(headerView)
		headerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
		headerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
		headerView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
		headerHCst = headerView.heightAnchor.constraint(equalToConstant: headerH)
		headerHCst.isActive = true
	}
	
}

// MARK: - Private functions
extension HomeViewController {
	
}


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
