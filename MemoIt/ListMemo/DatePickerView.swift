//
//  DatePickerView.swift
//  MemoIt
//
//  Created by mk mk on 5/8/19.
//  Copyright © 2019 MC2. All rights reserved.
//

import UIKit 
import MKCalendarView

class DatePickerView: UIView {

	// MARK: - Properties
	// - Variables
	// Selected date
	private var selectedDate = Date()
	// Selected time
	private var selectedTime = Date()
	
	// - Closures
	var pickedDate: ((Date) -> Void)?
	var backToKeyboard: (() -> Void)?
	
	// MARK: - Views
	// Date time segment
	private lazy var dateTimeSegment: UISegmentedControl = {
		let seg = UISegmentedControl(items: ["Date", "Time"])		
		seg.selectedSegmentIndex = 0
		seg.tintColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
		return seg
	}()
	
	// Calendar view
	private lazy var calendarView = CalenderView()
	
	// Time picker view
	private lazy var timePicker: UIDatePicker = {
		let picker = UIDatePicker()
		picker.datePickerMode = .time
		return picker
	}()
	
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

// MARK: - Private function
extension DatePickerView {
	private func selectDate(date: Date) {
		print("date: \(date)")
		self.selectedDate = date
		updateSelectDate()
	}
	
	private func updateSelectDate() {
		// Calendar
		let calendar = Calendar.current
		// Date components
		let year = calendar.component(.year, from: selectedDate)
		let month = calendar.component(.month, from: selectedDate)
		let day = calendar.component(.day, from: selectedDate)
		let hour = calendar.component(.hour, from: selectedTime)
		let minute = calendar.component(.minute, from: selectedTime)		
		
		// Date formatter
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
		dateFormatter.locale = .current
		let dateFromStr = dateFormatter.date(from: String(format: "%d-%d-%dT%d:%d:00", year, month, day, hour, minute))
		self.pickedDate?(dateFromStr!)
	}
}

// MARK: - Actions
extension DatePickerView {
	// Go back action
	@objc private func goBackAction() {
		print("back")
		self.backToKeyboard?()
	}
	
	// Segment action
	@objc private func segmentAction(_ sender: UISegmentedControl) {
		switch sender.selectedSegmentIndex {
		case 0:
			// Date picker
			calendarView.isHidden = false
			timePicker.isHidden = true
			
		default:
			// Time picker
			timePicker.isHidden = false
			calendarView.isHidden = true
		}
	}
	
	// Time picker action
	@objc private func timePickerAction(_ sender: UIDatePicker) {
		self.selectedTime = sender.date
		updateSelectDate()
	}
}

// MARK: - Setup UI
extension DatePickerView {
	private func setup() {
		backgroundColor = .white
		
		// Date time segment
		dateTimeSegment.addTarget(self, action: #selector(segmentAction(_:)), for: .valueChanged)
		addSubview(dateTimeSegment)
		dateTimeSegment.translatesAutoresizingMaskIntoConstraints = false
		dateTimeSegment.topAnchor.constraint(equalTo: topAnchor, constant: Padding.p2).isActive = true
		dateTimeSegment.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
		dateTimeSegment.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5).isActive = true
		
		// Go back button
		let gobackBtn = UIButton(type: .custom)
		gobackBtn.setImage(#imageLiteral(resourceName: "GoBack").withRenderingMode(.alwaysTemplate), for: .normal)
		gobackBtn.tintColor = #colorLiteral(red: 0.7540688515, green: 0.7540867925, blue: 0.7540771365, alpha: 1)
		gobackBtn.addTarget(self, action: #selector(goBackAction), for: .touchUpInside)
		addSubview(gobackBtn)
		gobackBtn.translatesAutoresizingMaskIntoConstraints = false
		gobackBtn.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
		gobackBtn.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
		gobackBtn.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
		gobackBtn.heightAnchor.constraint(equalToConstant: UIHelper.defaultH).isActive = true
		
		// Calendar view
		calendarView.selectedDate = selectDate
		addSubview(calendarView)
		calendarView.translatesAutoresizingMaskIntoConstraints = false
		calendarView.topAnchor.constraint(equalTo: dateTimeSegment.bottomAnchor, constant: Padding.p2).isActive = true
		calendarView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Padding.p20).isActive = true
		calendarView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Padding.p20).isActive = true
		calendarView.bottomAnchor.constraint(equalTo: gobackBtn.topAnchor, constant: -Padding.p2).isActive = true
		
		// Time picker
		timePicker.addTarget(self, action: #selector(timePickerAction(_:)), for: .valueChanged)
		addSubview(timePicker)
		timePicker.translatesAutoresizingMaskIntoConstraints = false
		timePicker.topAnchor.constraint(equalTo: dateTimeSegment.bottomAnchor, constant: Padding.p2).isActive = true
		timePicker.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Padding.p20).isActive = true
		timePicker.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Padding.p20).isActive = true
		timePicker.bottomAnchor.constraint(equalTo: gobackBtn.topAnchor, constant: -Padding.p2).isActive = true
		timePicker.isHidden = true
	}
}
