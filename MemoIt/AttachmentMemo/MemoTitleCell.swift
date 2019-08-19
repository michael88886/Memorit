//
//  MemoTitleCell.swift
//  ScheMo
//
//  Created by MICA17 on 2/3/19.
//  Copyright © 2019 MC2. All rights reserved.
//

import UIKit

final class MemoTitleCell: UITableViewCell {
	
	// MARK: - Properties
	// - Color tag size
	private let ctSize: CGFloat = 32
	
	// MARK: - Views
	// Title text field
	private lazy var titleField = UITextField()
	
	// MARK: - Override functions
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		loadView()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		loadView()
	}
}

// MARK: - Public function
extension MemoTitleCell {
	// Get memo title
	func memoTitle() -> String? {
		return titleField.text
	}
	
	// Hide keyboard
	func hideKeyboard() {
		titleField.resignFirstResponder()
	}
}

// MARK: - Setup UI
extension MemoTitleCell {
	private func loadView() {
		// Title field
		titleField.placeholder = "Untitle memo"
		titleField.font = UIFont.systemFont(ofSize: 24, weight: .light)
		titleField.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(titleField)
		titleField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Padding.p20).isActive = true
		titleField.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -Padding.p20).isActive = true
		titleField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Padding.p10).isActive = true
		titleField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Padding.p10).isActive = true
	}
}
