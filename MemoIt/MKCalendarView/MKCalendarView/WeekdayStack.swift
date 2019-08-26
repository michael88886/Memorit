//
//  WeekdayStack.swift
//  CalendarView
//
//  Created by mk mk on 3/8/19.
//  Copyright © 2019 MC2. All rights reserved.
//

import UIKit

class WeekdayStack: UIStackView {
	// MARK: - Properties
	// - Constants
	// Weekday text
	private let weekdayText = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
	
	// - Variables
	// Theme color
	private var themeColor: UIColor = #colorLiteral(red: 0.4756349325, green: 0.4756467342, blue: 0.4756404161, alpha: 1)
	// Font size
	private var fontSize: CGFloat = 0
	
	// MARK: - Custom init
	convenience init(color: UIColor) {
		self.init()
		self.themeColor = color
		configure()
	}
	
	convenience init(color: UIColor, fontSize: CGFloat) {
		self.init()
		self.themeColor = color
		self.fontSize = fontSize
		configure()
	}
}

// MARK: - Private funcitons
extension WeekdayStack {
	private func weekdayLabel(title: String) -> UILabel {
		let lb = UILabel()
		if fontSize > 0 { lb.font = UIFont.systemFont(ofSize: fontSize) }
		lb.text = title
		lb.adjustsFontSizeToFitWidth = true
		lb.minimumScaleFactor = 0.15
		lb.textAlignment = .center
		lb.textColor = themeColor
		if title == "Sun" || 
			title == "Sat" {
			lb.textColor = themeColor.withAlphaComponent(0.5)
		}
		return lb
	}
}

// MARK: - Configure
extension WeekdayStack {
	private func configure() {
		axis = .horizontal
		alignment = .center
		distribution = .fillEqually
		
		// Add text
		for text in weekdayText {
			let lb = weekdayLabel(title: text)
			addArrangedSubview(lb)
		}
	}
}
