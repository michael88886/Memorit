//
//  ListTableCell.swift
//  MemoIt
//
//  Created by mk mk on 6/6/19.
//  Copyright © 2019 MC2. All rights reserved.
//

import UIKit

class ListTableCell: UITableViewCell {
	
	// MARK: - Properties
	// - Constants
	// Button height
	private let btnSize: CGFloat = 28
	// Corner radius
	private let cornerRadius: CGFloat = 6
	// Color view width
	private let colorViewW: CGFloat = 4
	// Reminder height
	private let reminderH: CGFloat = 18
	
	// - Variables
	// Reminder group height constraint
	private var reminderHCst = NSLayoutConstraint()
	//  Current cell type
	private var isDone: Bool = false
	// Backup string
	private var backupStr: String?
	
	// - Closure
	var updateCompletion: ((ListTableCell, Bool) -> Void)?
	
	
	// MARK: - Views
	// - Top container
	private lazy var topContainer = UIView()
	
	// - Title field
	private lazy var textView: UITextView = {
		let tv = UITextView()
		tv.backgroundColor = .clear
		tv.tintColor = #colorLiteral(red: 0.6642242074, green: 0.6642400622, blue: 0.6642315388, alpha: 1)
		tv.isUserInteractionEnabled = false
		tv.isSelectable = false
		tv.isScrollEnabled = false
		tv.isEditable = false
		tv.showsHorizontalScrollIndicator = false
		tv.allowsEditingTextAttributes = true
		return tv
	}()
	
	// Left button
	private lazy var leftBtn: UIButton = {
		let btn = UIButton(type: .custom)
		btn.setImage(#imageLiteral(resourceName: "Select_list").withRenderingMode(.alwaysTemplate), for: .normal)
		btn.tintColor = #colorLiteral(red: 1, green: 0.8039215686, blue: 0, alpha: 1)
		return btn
	}()
	
	// Color tag view
	private lazy var colorView = UIView()
	
	// Reminder stack
	private lazy var reminderStack: UIStackView = {
		let grp = UIStackView()
		grp.axis = .horizontal
		grp.distribution = .fill
		grp.spacing = 5
		return grp
	}()
	
	// Reminder label
	private lazy var reminderLabel: UILabel = {
		let lb = UILabel()
		lb.textAlignment = .left
		lb.textColor = #colorLiteral(red: 0.7540688515, green: 0.7540867925, blue: 0.7540771365, alpha: 1)
		lb.font = UIFont.systemFont(ofSize: 12)
		return lb
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

// MARK: - Override functions
extension ListTableCell {
	// Ready for reuse cell
	override func prepareForReuse() {
		super .prepareForReuse()
		// Reset flag and complete image
		isDone = false
		setCompleteImage(complete: isDone)
		// Reset Text view
		textView.text = ""
		// Reset reminder group height constraint
		reminderHCst.constant = 0
		// Reset color view color
		colorView.backgroundColor = .clear
	}
}

// MARK: - Public functions
extension ListTableCell {
	// - Load data
	func feedData(data: ListItemModel) {
		// Title
		let attrStr = NSAttributedString(string: data.title, 
										 attributes: [NSAttributedString.Key.foregroundColor : #colorLiteral(red: 0.370555222, green: 0.3705646992, blue: 0.3705595732, alpha: 1), 
													  NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)])
		self.textView.attributedText = attrStr 
		// Task completion
		isDone = data.isDone
		// Set complete image
		setCompleteImage(complete: isDone)
		// Color 
		colorView.backgroundColor = data.color		
		// Reminder
		if let date = data.reminder {
			reminderLabel.text = CalendarHelper.dateToString(date: date, format: .listReminder)
			reminderHCst.constant = reminderH			
		}
	}
	
	// Set select image
	func setCompleteImage(complete: Bool) {
		// Attribute string
		let attibuteString = NSMutableAttributedString(attributedString: self.textView.attributedText)
		// Range
		let range = NSRange(location: 0, length: attibuteString.length)
		
		if complete {
			leftBtn.setImage(#imageLiteral(resourceName: "Selected_list").withRenderingMode(.alwaysTemplate), for: .normal)
			attibuteString.addAttributes([NSAttributedString.Key.strikethroughStyle : NSUnderlineStyle.single.rawValue], range: range)
			self.textView.attributedText = attibuteString
		}
		else {
			leftBtn.setImage(#imageLiteral(resourceName: "Select_list").withRenderingMode(.alwaysTemplate), for: .normal)
			attibuteString.removeAttribute(NSAttributedString.Key.strikethroughStyle, range: range)
			self.textView.attributedText = attibuteString
		}
	}
}

// MARK: - Private functions
extension ListTableCell {	
	// Hide keyboard
	func hideKeyboard() {
		textView.resignFirstResponder()
	}
}

// MARK: - Actions
extension ListTableCell {
	// Actions
	@objc private func completeAction() {
		isDone = !isDone
		self.updateCompletion?(self, isDone)
	}
}

// MARK: - UI setup
extension ListTableCell {
	// Setup cell view
	private func loadView() {
		// Selection style
		selectionStyle = .none
		// Setup background color
//		        backgroundColor = .orange
		
		// Top container
		topContainer.backgroundColor = .white
		topContainer.layer.cornerRadius = cornerRadius
		topContainer.layer.shadowColor = #colorLiteral(red: 0.2605174184, green: 0.2605243921, blue: 0.260520637, alpha: 1)
		topContainer.layer.shadowOpacity = 0.2
		topContainer.layer.shadowRadius = 2.0
		topContainer.layer.shadowOffset = CGSize.zero		
		contentView.addSubview(topContainer)
		topContainer.translatesAutoresizingMaskIntoConstraints = false
		topContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Padding.p5).isActive = true
		topContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Padding.p10).isActive = true
		topContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Padding.p10).isActive = true
		contentView.bottomAnchor.constraint(equalTo: topContainer.bottomAnchor, constant: Padding.p5).isActive = true
		
		// Color view 
		topContainer.addSubview(colorView)
		colorView.translatesAutoresizingMaskIntoConstraints = false
		colorView.topAnchor.constraint(equalTo: topContainer.topAnchor).isActive = true
		colorView.leadingAnchor.constraint(equalTo: topContainer.leadingAnchor, constant: Padding.p5).isActive = true
		colorView.bottomAnchor.constraint(equalTo: topContainer.bottomAnchor).isActive = true
		colorView.widthAnchor.constraint(equalToConstant: colorViewW).isActive = true
		
		// Left button
		leftBtn.addTarget(self, action: #selector(completeAction), for: .touchUpInside)
		topContainer.addSubview(leftBtn)
		leftBtn.translatesAutoresizingMaskIntoConstraints = false
		leftBtn.leadingAnchor.constraint(equalTo: colorView.trailingAnchor, constant: Padding.p10) .isActive = true
		leftBtn.centerYAnchor.constraint(equalTo: topContainer.centerYAnchor).isActive = true
		leftBtn.heightAnchor.constraint(equalToConstant: btnSize).isActive = true
		leftBtn.widthAnchor.constraint(equalTo: leftBtn.heightAnchor).isActive = true
		
		// Title field
		topContainer.addSubview(textView)
		textView.translatesAutoresizingMaskIntoConstraints = false
		textView.topAnchor.constraint(equalTo: topContainer.topAnchor, constant: Padding.p5).isActive = true
		textView.leadingAnchor.constraint(equalTo: leftBtn.trailingAnchor, constant: Padding.p5).isActive = true
		textView.trailingAnchor.constraint(equalTo: topContainer.trailingAnchor, constant: -Padding.p20).isActive = true
		
		// Reminder group	
		topContainer.addSubview(reminderStack)
		reminderStack.translatesAutoresizingMaskIntoConstraints = false
		reminderStack.topAnchor.constraint(equalTo: textView.bottomAnchor).isActive = true
		reminderStack.leadingAnchor.constraint(equalTo: textView.leadingAnchor).isActive = true
		reminderHCst = reminderStack.heightAnchor.constraint(equalToConstant: 0)
		reminderHCst.isActive = true
		topContainer.bottomAnchor.constraint(equalTo: reminderStack.bottomAnchor, constant: Padding.p5).isActive = true
		
		
		// Reminder tag icon
		let reminderIcon = UIImageView(image: #imageLiteral(resourceName: "Bell").withRenderingMode(.alwaysTemplate))
		reminderIcon.tintColor = #colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1)
		reminderStack.addArrangedSubview(reminderIcon)
		reminderIcon.translatesAutoresizingMaskIntoConstraints = false
		reminderIcon.widthAnchor.constraint(equalTo: reminderStack.heightAnchor).isActive = true
		reminderIcon.heightAnchor.constraint(equalTo: reminderIcon.widthAnchor).isActive = true
		
		// Reminder label
		reminderStack.addArrangedSubview(reminderLabel)
	}
}
