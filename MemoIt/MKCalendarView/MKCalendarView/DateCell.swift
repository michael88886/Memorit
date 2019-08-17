//
//  DateCell.swift
//  CalendarView
//
//  Created by mk mk on 4/8/19.
//  Copyright © 2019 MC2. All rights reserved.
//

import UIKit

class DateCell: UICollectionViewCell {
    
	// MARK: - Properties
	// - Constant
	// Corner radius
	private let cornerRadius: CGFloat = 8.0
	
	// - Variables
	// Cell date
	private var date = Date()
	// Date color
	private var dateColor: UIColor = #colorLiteral(red: 0.6642242074, green: 0.6642400622, blue: 0.6642315388, alpha: 1)
	// Today view color
	private var todayViewColor: UIColor = #colorLiteral(red: 1, green: 0.4932718873, blue: 0.4739984274, alpha: 1)
	// Highlight text color
	private var highlightTextColor: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
	// Select view color
	private var selectViewColor: UIColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
	// Is today flag
	private var isToday: Bool = false
	
	// MARK: - View
	// Date label
	private lazy var dateLabel: UILabel = {
		let lb = UILabel()
		lb.textColor = dateColor
		lb.textAlignment = .center
		lb.adjustsFontSizeToFitWidth = true
		lb.minimumScaleFactor = 0.15
		return lb
	}()
	
	// Today view
	private lazy var todayView = UIView()
	
	// Select view
	private lazy var selectView = UIView()
	
	// MARK: - Override init
	override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setup()
	}
}

// MARK: - Override functions
extension DateCell {
	override func prepareForReuse() {
		super.prepareForReuse()
		isUserInteractionEnabled = true
		isToday = false
		// Reset date
		self.date = Date()
		// Reset label
		dateLabel.text = ""
		dateLabel.textColor = dateColor
		// Reset for today view
		todayView.isHidden = true
		// Reset for select view
		selectView.isHidden = true
	}
}

// MARK: - Public function
extension DateCell {
	// Set date color
	func dateColor(color: UIColor) {
		self.dateColor = color
		dateLabel.textColor = color
	}
	
	// Set today view color
	func setTodayViewColor(color: UIColor) {
		self.todayViewColor = color
	}
	
	// Set select view color
	func setSelectViewColor(color: UIColor) {
		self.selectViewColor = color
	}
	
	// Set highlight text color
	func setHighlightTextColor(color: UIColor) {
		self.highlightTextColor = color
	}
	
	// Set text
	func setText(text: String) {
		dateLabel.text = text
	}
	
	// Set date
	func setDate(date: Date) {
		// Assign date
		self.date = date
		
		// If is Today?
		if Calendar.current.isDateInToday(self.date) {
			isToday = true
			dateLabel.textColor = highlightTextColor
			todayView.isHidden = false
		}
	}
	
	// Select cell
	func selectCell() -> Date {
		self.selectView.isHidden = false
		self.dateLabel.textColor = highlightTextColor
		return self.date
	}
	
	// Deselect cell
	func deselectCell() {
		self.selectView.isHidden = true
		if !isToday {
			self.dateLabel.textColor = dateColor
		}
	}
}

// MARK: - Setup UI
extension DateCell {
	private func setup() {
		// Date label
		contentView.addSubview(dateLabel)
		dateLabel.translatesAutoresizingMaskIntoConstraints = false
		dateLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
		dateLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
		
		// Today view
		todayView.backgroundColor = todayViewColor
		todayView.layer.cornerRadius = cornerRadius
		contentView.insertSubview(todayView, at: 0)
		todayView.translatesAutoresizingMaskIntoConstraints = false
		todayView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Padding.p4).isActive = true
		todayView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Padding.p4).isActive = true
		todayView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Padding.p4).isActive = true
		todayView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Padding.p4).isActive = true
		todayView.isHidden = true
		
		// Select view
		selectView.backgroundColor = selectViewColor
		selectView.layer.cornerRadius = cornerRadius
		contentView.insertSubview(selectView, aboveSubview: todayView)
		selectView.translatesAutoresizingMaskIntoConstraints = false
		selectView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Padding.p4).isActive = true
		selectView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Padding.p4).isActive = true
		selectView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Padding.p4).isActive = true
		selectView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Padding.p4).isActive = true
		selectView.isHidden = true
	}
}
