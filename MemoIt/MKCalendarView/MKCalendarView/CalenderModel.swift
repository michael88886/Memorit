//
//  CalenderModel.swift
//  CalendarView
//
//  Created by mk mk on 3/8/19.
//  Copyright © 2019 MC2. All rights reserved.
//

import UIKit


class CalendarModel: NSObject {
	
	// Date formation
	enum DateFormat {
		case day
		case monthYear
		
		func stringFromDate(date: Date) -> String {
			let formatter = DateFormatter()
			switch self {
			case .day:
				formatter.dateFormat = "d"
			
			case .monthYear:
				formatter.dateFormat = "MMMM yyyy"	
			}
			return (formatter.string(from: date))
		}
	}
	
	// MARK: - Properties
	// - Constants
	// Cell id
	let cellID = "DateCell"
	
	// - Variables
	private var calendarDate = Date()
	
	// - Closure
	var updateCalendar: (() -> Void)?
	
	// MARK: - Custom init
	override init() {
		super.init()
		setup()
	}	
}

// MARK: - Public funcitons
extension CalendarModel {
	// Last month
	func prevMonth() {
		var lastMtnComp = DateComponents()
		lastMtnComp.month = -1
		let lastMth = Calendar.current.date(byAdding: lastMtnComp, to: calendarDate)!
		calendarDate = lastMth
		self.updateCalendar?()
	}
	
	// Next month
	func nextMonth() {
		var nextMthComp = DateComponents()
		nextMthComp.month = +1
		let nextMth = Calendar.current.date(byAdding: nextMthComp, to: calendarDate)!
		calendarDate = nextMth
		self.updateCalendar?()
	}
	
	// Update month label
	func updateMonthLabel(label: UILabel) {
		label.text = DateFormat.monthYear.stringFromDate(date: calendarDate)
	}
	
	// Cells for month
	func cellsInMonth() -> Int {
		return firstDateOfMonth() + daysInMonth()
	}
	
	// Configure cell
	func configureCell(_ collectionView: UICollectionView, _ indexpath: IndexPath) -> DateCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexpath) as! DateCell
		let firstDate = firstDateOfMonth()
		let monthdays = daysInMonth()
		let index = indexpath.row
		var  day: Int = 0
		if (index >= firstDate) && 
			(index <= firstDate + monthdays - 1) {
			// Date in Int
			day = index - firstDate + 1
			// Set date text
			cell.setText(text: String(day))
			
			// Cell date
			let calendar = Calendar.current
			var dateComp = calendar.dateComponents([.year, .month, .day], from: calendarDate)
			dateComp.day = day
			if let dayInCell = calendar.date(from: dateComp) {
				cell.setDate(date: dayInCell)
			}
		}
		else {
			cell.isUserInteractionEnabled = false
		}
		return cell
	}
}

// MARK: - Private functions
extension CalendarModel {
	// First date of month
	private func firstDateOfMonth() -> Int {
		var calendar = Calendar.current
		calendar.firstWeekday = 1
		var component = calendar.dateComponents([.year, .month, .day], from: calendarDate)
		component.day = 1
		
		let firstDate = calendar.date(from: component)
		let firstWeekDay = calendar.ordinality(of: .weekday, in: .weekOfMonth, for: firstDate!)
		return firstWeekDay! - 1
	}
	
	// Days in month
	private func daysInMonth() -> Int {
		let days: Range = Calendar.current.range(of: .day, in: .month, for: calendarDate)!
		return days.count
	}
}

// MARK: - Configure
extension CalendarModel {
	private func setup() {
		
	}
}
