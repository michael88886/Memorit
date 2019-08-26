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
	// - Constant
	// Color tag size
	private let ctSize: CGFloat = 32
	
	// - Closure
	var updateTitle: ((String?) -> Void)?
	
	
	// MARK: - Views
	// Title text field
	private(set) lazy var titleField = UITextField()
	
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
	func setTitle(title: String) {
		titleField.text = title
	}
	
	// Hide keyboard
	func hideKeyboard() {
		titleField.resignFirstResponder()
	}
}

// MARK: - Actions
extension MemoTitleCell {
	@objc private func textFieldEditing(_ textField: UITextField) {
		self.updateTitle?(textField.text)
	}
}

// MARK: - Setup UI
extension MemoTitleCell {
	private func loadView() {
		// Title field
		titleField.placeholder = "Untitle memo"
		titleField.font = UIFont.systemFont(ofSize: 24, weight: .light)
		titleField.addTarget(self, action: #selector(textFieldEditing(_:)), for: .editingChanged)
		contentView.addSubview(titleField)
		titleField.translatesAutoresizingMaskIntoConstraints = false
		titleField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Padding.p20).isActive = true
		titleField.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -Padding.p20).isActive = true
		titleField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Padding.p10).isActive = true
		titleField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Padding.p10).isActive = true
	}
}
