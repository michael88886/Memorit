//
//  ListTableCell.swift
//  MemoIt
//
//  Created by mk mk on 6/6/19.
//  Copyright © 2019 MC2. All rights reserved.
//

import UIKit

private enum ListCellMode {
	case add
	case pending
	case completed
}

class ListTableCell: UITableViewCell {
	
	// MARK: - Properties
	// - Constants
	// Button height
	private let btnSize: CGFloat = 28
	// Corner radius
	private let cornerRadius: CGFloat = 4
	
	// - Variables
	//  Current cell type
	private var currType: ListCellMode = .add
	// Backup string
	private var backupStr: String?
	
	// - Closures
	var startEditing: ((ListTableCell) -> Void)?
	var editingText: ((ListTableCell) -> Void)?
	var endEditing: ((ListTableCell) -> Void)?
	var refreshCell: ((ListTableCell, String) -> Void)?
	var addItem: ((String) -> Void)?
	var taskCompleted: ((ListTableCell, Bool) -> Void)?
	
	
	// MARK: - Views
	// - Top container
	private lazy var topContainer = UIView()
	
	// - Title field
	private lazy var textView: UITextView = {
		let tv = UITextView()
		tv.backgroundColor = .clear
		tv.tintColor = #colorLiteral(red: 0.6642242074, green: 0.6642400622, blue: 0.6642315388, alpha: 1)
		tv.textColor = #colorLiteral(red: 0.370555222, green: 0.3705646992, blue: 0.3705595732, alpha: 1)
		tv.isScrollEnabled = false
		tv.showsVerticalScrollIndicator = false
		tv.showsHorizontalScrollIndicator = false
		tv.allowsEditingTextAttributes = true
		tv.adjustsFontForContentSizeCategory = true
		tv.autocorrectionType = .no
		tv.typingAttributes = [.font: UIFont.systemFont(ofSize: 20),
							   .foregroundColor: #colorLiteral(red: 0.6642242074, green: 0.6642400622, blue: 0.6642315388, alpha: 1)]
		return tv
	}()
	
	// Right button
	private lazy var rightBtn: UIButton = {
		let btn = UIButton(type: .custom)
		btn.setImage(#imageLiteral(resourceName: "Plus44").withRenderingMode(.alwaysTemplate), for: .normal)
		btn.tintColor = #colorLiteral(red: 1, green: 0.8039215686, blue: 0, alpha: 1)
		btn.addTarget(self, action: #selector(rightAction), for: .touchUpInside)
		return btn
	}()
	
	
	// MARK: - Custom init
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		loadView()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		loadView()
	}
}

// MARK: - Private functions
extension ListTableCell {
	// - Load data
	func feedData(data: ListModel) {
		// Title
		self.textView.text = data.title
		// State
		if data.isDone {
			currType = .completed
			rightBtn.setImage(#imageLiteral(resourceName: "Selected_list").withRenderingMode(.alwaysTemplate), for: .normal)
		}
		else {
			currType = .pending
			rightBtn.setImage(#imageLiteral(resourceName: "Select_list").withRenderingMode(.alwaysTemplate), for: .normal)
		}
	}
	
	// Hide keyboard
	func hideKeyboard() {
		textView.resignFirstResponder()
	}
	
	// If allow to edit cell
	func allowEdit() -> Bool {
		if currType == .add { return false }
		return true
	}
}

// MARK: - Actions
extension ListTableCell {
	
	// Actions
	@objc private func rightAction() {
		print("Right action")
		switch currType {
		case .add:
			textView.becomeFirstResponder()
		case .pending:
			// Pending -> Complete
			currType = .completed
			rightBtn.setImage(#imageLiteral(resourceName: "Selected_list").withRenderingMode(.alwaysTemplate), for: .normal)
			taskCompleted?(self, true)
		case .completed:
			// Complete -> Pending
			currType = .pending
			rightBtn.setImage(#imageLiteral(resourceName: "Select_list").withRenderingMode(.alwaysTemplate), for: .normal)
			taskCompleted?(self, false)
		}
	}
}

// MARK: - UI setup
extension ListTableCell {
	// Setup cell view
	private func loadView() {
		// Selection style
		selectionStyle = .none
		// Setup background color
		backgroundColor = .clear
		
		// Top container
		topContainer.backgroundColor = .white
		topContainer.translatesAutoresizingMaskIntoConstraints = false
		topContainer.layer.cornerRadius = cornerRadius
		topContainer.layer.shadowColor = #colorLiteral(red: 0.2605174184, green: 0.2605243921, blue: 0.260520637, alpha: 1)
		topContainer.layer.shadowOpacity = 0.2
		topContainer.layer.shadowRadius = 2.0
		topContainer.layer.shadowOffset = CGSize.zero
		contentView.addSubview(topContainer)
		topContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Padding.p5).isActive = true
		topContainer.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: Padding.p10).isActive = true
		topContainer.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -Padding.p10).isActive = true
		contentView.bottomAnchor.constraint(equalTo: topContainer.bottomAnchor, constant: Padding.p5).isActive = true
		
		// Right icon
		rightBtn.translatesAutoresizingMaskIntoConstraints = false
		topContainer.addSubview(rightBtn)
		rightBtn.heightAnchor.constraint(equalToConstant: btnSize).isActive = true
		rightBtn.widthAnchor.constraint(equalTo: rightBtn.heightAnchor).isActive = true
		rightBtn.centerYAnchor.constraint(equalTo: topContainer.centerYAnchor).isActive = true
		rightBtn.rightAnchor.constraint(equalTo: topContainer.rightAnchor, constant: -Padding.p10) .isActive = true
		
		// Title field
		textView.translatesAutoresizingMaskIntoConstraints = false
		topContainer.addSubview(textView)
		textView.topAnchor.constraint(equalTo: topContainer.topAnchor, constant: Padding.p5).isActive = true
		textView.leftAnchor.constraint(equalTo: topContainer.leftAnchor, constant: Padding.p5).isActive = true
		textView.rightAnchor.constraint(equalTo: rightBtn.leftAnchor, constant: -Padding.p20).isActive = true
		topContainer.bottomAnchor.constraint(equalTo: textView.bottomAnchor, constant: Padding.p5).isActive = true
		textView.delegate = self
	}
}

// MARK: - Override functions
extension ListTableCell {
	// Ready for reuse cell
	override func prepareForReuse() {
		super .prepareForReuse()
		print("reuse")
		// Reset type
		currType = .add
		// Reset button
		rightBtn.setImage(#imageLiteral(resourceName: "Plus44"), for: .normal)
		// Reset Text view
		textView.text = ""
	}
}

// MARK: - UITextview delegate
extension ListTableCell: UITextViewDelegate {
	// Start editing
	func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
		print("start edit: ", self)
		// Backup text
		if currType != .add {
			backupStr = textView.text
		}
		self.startEditing?(self)
		return true
	}
	
	// Editing
	func textViewDidChange(_ textView: UITextView) {
		self.editingText?(self)
	}
	
	// End editing
	func textViewDidEndEditing(_ textView: UITextView) {
		print("end edit: ", self)
		let inputText = textView.text
		let updated: Bool = (backupStr == inputText) ? false : true
		
		// Validate input text
		if let trimText = inputText?.trimmingCharacters(in: .whitespacesAndNewlines), 
			trimText != "" {
			// Valid
			print("Valid input")
			if currType == .add {
				self.addItem?(trimText)
			}
			else {
				if updated {
					self.refreshCell?(self, trimText)
				}
			}
		}
		else {
			// Invalid
			print("Invalid input")
			if currType == .add {
				textView.text = ""
			}
			else {
				if updated {
					textView.text = backupStr
					refreshCell?(self, backupStr!)
				}
			}
		}
		
		// Reset backup string
		backupStr = nil
		self.endEditing?(self)
	}
}
