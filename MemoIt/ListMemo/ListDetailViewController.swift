//
//  ListDetailViewController.swift
//  MemoIt
//
//  Created by mk mk on 27/8/19.
//  Copyright © 2019 MC2. All rights reserved.
//

import UIKit
import MKCalendarView

final class ListDetailViewController: UIViewController {

	// MAKR: -Properties
	// - Constants
	// Cell id
	private let cellid = "DetailCell"
	
	// - Variables
	// List model
	private var listItemModel: ListItemModel
	// Detail table bottom constraint
	private var dtBCst = NSLayoutConstraint()
	// Selected color
	private var selectedColor: UIColor = .white
	// Selected reminder
	private var selectedReminder: Date?
	
	// MARK: - Views
	// Title text view
	private lazy var titleTextView: UITextView = {
		let txV = UITextView()
		txV.isEditable = true
		txV.isScrollEnabled = false
		txV.bounces = true
		txV.showsHorizontalScrollIndicator = false
		txV.showsVerticalScrollIndicator = false
		txV.textContainer.lineFragmentPadding = 0
		txV.adjustsFontForContentSizeCategory = true
		txV.allowsEditingTextAttributes = true
		txV.font = UIFont.systemFont(ofSize: 20)
		txV.textColor = #colorLiteral(red: 0.4756349325, green: 0.4756467342, blue: 0.4756404161, alpha: 1)
		return txV
	}()
	
	// Detail table
	private lazy var detailTable: UITableView = {
		let tb = UITableView(frame: .zero, style: .plain)
		tb.allowsMultipleSelection = false
		tb.allowsSelection = false
		tb.separatorStyle = .none
		tb.keyboardDismissMode = .onDrag
		tb.estimatedRowHeight = 44
		tb.rowHeight = UITableView.automaticDimension
		return tb
	}()
	
	// Title cell
	private lazy var titleCell: UITableViewCell = {
		let cell = UITableViewCell()
		// Title cell
		let titleLabel = UILabel()
		titleLabel.textAlignment = .left
		titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .bold)
		titleLabel.textColor = #colorLiteral(red: 0.370555222, green: 0.3705646992, blue: 0.3705595732, alpha: 1)
		titleLabel.text = "Title"
		cell.contentView.addSubview(titleLabel)
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		titleLabel.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: Padding.p5).isActive = true
		titleLabel.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: Padding.p20).isActive = true		
		
		// Add title view
		titleTextView.delegate = self
		cell.contentView.addSubview(titleTextView)
		titleTextView.translatesAutoresizingMaskIntoConstraints = false
		titleTextView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor).isActive = true
		titleTextView.leadingAnchor.constraint(equalTo: cell.contentView.safeAreaLayoutGuide.leadingAnchor, constant: Padding.p20).isActive = true
		titleTextView.trailingAnchor.constraint(equalTo: cell.contentView.safeAreaLayoutGuide.trailingAnchor, constant: -Padding.p20).isActive = true
		titleTextView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -Padding.p5).isActive = true
		return cell
	}()
	
	// Color cell
	private lazy var colorCell = ListItemColorCell()
	
	// Reminder cell
	private lazy var reminderCell = ListReminderCell()
	
	// MARK: - Override init
	init(data: ListItemModel) {
		self.listItemModel = data
		self.selectedColor = data.color
		if let reminder = data.reminder {
			self.selectedReminder = reminder
		}
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError()
	}
}

// MARK: - Override functions
extension ListDetailViewController {
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Keyboard show / hide notification
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardAction(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardAction(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
		
		// Assign closure
		colorCell.selectedColor = setColor
		reminderCell.selectedDate = setReminder
		
		// Set title text
		titleTextView.text = listItemModel.title
		
		// Set color cell
		colorCell.setSelectColor(color: selectedColor)
		
		// Set reminder cell
		if let reminder = self.selectedReminder {
			reminderCell.setReminder(date: reminder)
		}
	}	
}

// MARK: - Private function
extension ListDetailViewController {
	// Set select color
	private func setColor(color: UIColor) {
		self.selectedColor = color
	}
	
	// Set select reminder
	private func setReminder(reminder: Date?) {
		if let reminder = reminder {
			self.selectedReminder = reminder
		}
	}
}


// MARK: - Actions
extension ListDetailViewController {
	// Keyboard action
	@objc private func keyboardAction(_ notification: Notification) {
		guard let userInfo = notification.userInfo else { return }
		guard let duration: TimeInterval = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
		
		if notification.name == UIResponder.keyboardWillShowNotification {
			// Show keyboard
			// Show keyboard
			guard let rectValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
			// Keyboard height
			let kbH: CGFloat = rectValue.cgRectValue.height
			// Update constraint
			dtBCst.constant = -kbH + self.view.safeAreaInsets.bottom
		}
		else {
			// Hide keyboard
			dtBCst.constant = 0
		}
		
		UIView.animate(withDuration: duration) { 
			self.view.layoutIfNeeded()
		}
	}
	
	// Back action
	@objc private func dismissAction() {
		// Hide keyboard
		view.endEditing(true)
		
		// Save data
		listItemModel.title = titleTextView.text
		listItemModel.color = selectedColor
		listItemModel.reminder = selectedReminder
		
		let userInfo = ["data" : listItemModel]
		NotificationCenter.default.post(name: .reloadListTable, object: nil, userInfo: userInfo)
		
		DispatchQueue.main.async {
			self.navigationController?.popViewController(animated: true)
		}
	}
}


// MARK: - Delegates
// MARK; - UITableView delegate / data source
extension ListDetailViewController: UITableViewDataSource, UITableViewDelegate {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 3
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch indexPath.row {
		case 0:
			return titleCell
		case 1:
			return colorCell
		case 2:
			return reminderCell
		default:
			return UITableViewCell()
		} 
	}
	
	
}

// MARK: - Delegates
// MARK: - UITextView delegate
extension ListDetailViewController: UITextViewDelegate {
	func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
		if textView.textColor?.cgColor.alpha == UIHelper.placeholderAlpha {
			textView.text = ""
		}
		return true
	}
	
	func textViewDidChange(_ textView: UITextView) {
		let size = textView.bounds.size
		let newSize = textView.sizeThatFits(CGSize(width: size.width, height: CGFloat.greatestFiniteMagnitude))
		if size.height != newSize.height {
			UIView.setAnimationsEnabled(false)
			detailTable.beginUpdates()
			detailTable.endUpdates()
			UIView.setAnimationsEnabled(true)
			
			if let thisIndexpath = detailTable.indexPath(for: titleCell) {
				detailTable.scrollToRow(at: thisIndexpath, at: .bottom, animated: true)
			}
		}
	}
	
	func textViewDidEndEditing(_ textView: UITextView) {
		if textView.text.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
			textView.text = "Add task title"
			textView.textColor = #colorLiteral(red: 0.4756349325, green: 0.4756467342, blue: 0.4756404161, alpha: 1).withAlphaComponent(UIHelper.placeholderAlpha)
		}
	}
}

// MARK: - Setup UI 
extension ListDetailViewController {
	override func loadView() {
		super.loadView()
		view.backgroundColor = .white
		
		// Navigation bar
		navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1),
																   NSAttributedString.Key.font: UIFont.systemFont(ofSize: 24)]
		title = "Edit task"
		
		// Left button
		let leftBtn = UIButton(type: .custom)
		leftBtn.setImage(#imageLiteral(resourceName: "NaviBack44"), for: .normal)
		leftBtn.addTarget(self, action: #selector(dismissAction), for: .touchUpInside)
		navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftBtn)
		
		
		// Table view
		detailTable.delegate = self
		detailTable.dataSource = self
		view.addSubview(detailTable)
		detailTable.translatesAutoresizingMaskIntoConstraints = false
		detailTable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
		detailTable.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
		detailTable.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
		dtBCst = detailTable.bottomAnchor.constraint(equalTo: view.bottomAnchor)
		dtBCst.isActive = true
	}
}


// MARK: - ++++++ --
// MARK: - Cells

// MARK: - Color picker cell
final class ListItemColorCell: UITableViewCell {
	
	// MARK: - Properties
	// - Constants
	// Color list
	private let colorList: [UIColor] = [#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1), #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1), #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1), #colorLiteral(red: 1, green: 0.4932718873, blue: 0.4739984274, alpha: 1), #colorLiteral(red: 0.6642242074, green: 0.6642400622, blue: 0.6642315388, alpha: 1)]
	
	// - Variables
	// Color group
	private var colorGroup = [UIButton]()
	
	// - Closure
	// Select color
	var selectedColor: ((UIColor) -> Void)?
	
	// MARK: - Override init
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupUI()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError()
	}
}

// MARK: - Public function
extension ListItemColorCell {
	@objc func setSelectColor(color: UIColor) {
		for btn in colorGroup {
			if let bgColor = btn.backgroundColor {
				if color.isEqual(bgColor) {
					btn.layer.borderColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1).cgColor
					btn.layer.borderWidth = 2.0
				}
				else {
					btn.layer.borderColor = #colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1).cgColor
					btn.layer.borderWidth = 1.0
				}
			}
		}
	}
}

// MARK: - Actions
extension ListItemColorCell {
	// Color action
	@objc private func colorAction(_ sender: UIButton) {
		guard let color = sender.backgroundColor else { return }
		self.selectedColor?(color)
		setSelectColor(color: color)
	}
}

// MARK: - Setup UI
extension ListItemColorCell {
	private func setupUI() {
		// Color label
		let colorLabel = UILabel()
		colorLabel.textAlignment = .left
		colorLabel.font = UIFont.systemFont(ofSize: 14, weight: .bold)
		colorLabel.textColor = #colorLiteral(red: 0.370555222, green: 0.3705646992, blue: 0.3705595732, alpha: 1)
		colorLabel.text = "Color"
		contentView.addSubview(colorLabel)
		colorLabel.translatesAutoresizingMaskIntoConstraints = false
		colorLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Padding.p5).isActive = true
		colorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Padding.p20).isActive = true		
		
		// Color stack
		let colorStack = UIStackView()
		colorStack.axis = .horizontal
		colorStack.distribution = .fillEqually 
		colorStack.alignment = .center
		colorStack.spacing = 10
		contentView.addSubview(colorStack)
		colorStack.translatesAutoresizingMaskIntoConstraints = false
		colorStack.topAnchor.constraint(equalTo: colorLabel.bottomAnchor, constant: Padding.p10).isActive = true
		colorStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Padding.p20).isActive = true
		colorStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Padding.p20).isActive = true
		colorStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Padding.p10).isActive = true
		
		for color in colorList {
			let btn = UIButton(type: .custom)
			btn.backgroundColor = color
			btn.addTarget(self, action: #selector(colorAction(_:)), for: .touchUpInside)
			btn.layer.cornerRadius = 6.0
			btn.layer.borderColor = #colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1).cgColor
			btn.layer.borderWidth = 1.0
			colorStack.addArrangedSubview(btn)
			colorGroup.append(btn)
		}
	}
}


// MARK: - Reminder cell
final class ListReminderCell :UITableViewCell {
	// MARK: - Properties
	// - Contants
	// Icon size
	private let iconSize = CGSize(width: 24, height: 24)
	
	// - Variables
	// Select date
	private var selectDate = Date()
	// Select time
	private var selectTime = Date()
	
	// - Closures
	var selectedDate: ((Date?) -> Void)?
	
	
	// MARK: - Views
	// Segment control
	private lazy var segmentControl: UISegmentedControl = {
		let seg = UISegmentedControl(items: ["Date", "Time"])		
		seg.selectedSegmentIndex = 0
		seg.tintColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)	
		return seg
	}()
	
	// Reminder label button
	private lazy var reminderLabelBtn: UIButton = {
		let btn = UIButton(type: .custom)
		btn.backgroundColor = .white
		btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
		btn.setTitleColor(#colorLiteral(red: 0.6642242074, green: 0.6642400622, blue: 0.6642315388, alpha: 1), for: .normal)
		btn.setImage(#imageLiteral(resourceName: "Cross44").withRenderingMode(.alwaysTemplate), for: .normal)
		btn.imageView?.contentMode = .scaleAspectFit
		btn.tintColor = #colorLiteral(red: 0.6642242074, green: 0.6642400622, blue: 0.6642315388, alpha: 1)
		btn.semanticContentAttribute = .forceRightToLeft
		btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: -10)
		
		btn.layer.cornerRadius = 6.0
		btn.layer.borderWidth = 1.0
		btn.layer.borderColor = #colorLiteral(red: 0.6642242074, green: 0.6642400622, blue: 0.6642315388, alpha: 0.5).cgColor
		return btn
	}()
	
	// Calendar view
	private lazy var calendarView = CalenderView()
	
	// Time picker
	private lazy var timePicker: UIDatePicker = {
		let picker = UIDatePicker()
		picker.datePickerMode = .time
		return picker
	}()
	
	// MARK: - Override init 
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupUI()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError()
	}
}

// MARK: - Public funtion
extension ListReminderCell {
	func setReminder(date: Date) {
		self.selectDate = date
		self.selectTime = date
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy/MM/dd  HH:mm"
		reminderLabelBtn.setTitle(formatter.string(from: date), for: .normal)
		reminderLabelBtn.isHidden = false
	}
}

// MARK: - Private function
extension ListReminderCell {
	// Select date from calendar view
	private func selectDate(date: Date) {
		self.selectDate = date
		updateSelectDate()
	} 
	
	// Update select date
	private func updateSelectDate() {
		// Calendar
		let calendar = Calendar.current
		// Date components
		let year = calendar.component(.year, from: selectDate)
		let month = calendar.component(.month, from: selectDate)
		let day = calendar.component(.day, from: selectDate)
		let hour = calendar.component(.hour, from: selectTime)
		let minute = calendar.component(.minute, from: selectTime)		
		
		// Date formatter
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
		dateFormatter.locale = .current
		guard let dateFromStr = dateFormatter.date(from: String(format: "%d-%d-%dT%d:%d:00", year, month, day, hour, minute)) else { return }
		self.selectedDate?(dateFromStr)
		
		// Set button title
		dateFormatter.dateFormat = "yyyy/MM/dd  HH:mm"
		reminderLabelBtn.setTitle(dateFormatter.string(from: dateFromStr), for: .normal)
		reminderLabelBtn.isHidden = false
	}
}

// MARK: - Actions
extension ListReminderCell {
	// Segment
	@objc private func segmentAction(_ sender: UISegmentedControl) {
		switch sender.selectedSegmentIndex {
		case 0:
			// Calendar
			calendarView.isHidden = false
			timePicker.isHidden = true
			
		default:
			// Time picker
			timePicker.isHidden = false
			calendarView.isHidden = true
		}
	}
	
	// Timer picker action
	@objc private func timePickerAction(_ sender: UIDatePicker) {		
		self.selectTime = sender.date
		updateSelectDate()
	}
	
	// reminder button action
	@objc private func reminderButtonAction() {
		self.selectedDate?(nil)
		reminderLabelBtn.isHidden = true
	}
}

// MARK: - Setup UI
extension ListReminderCell {
	private func setupUI() {
		// Color label
		let rtlabel = UILabel()
		rtlabel.textAlignment = .left
		rtlabel.font = UIFont.systemFont(ofSize: 14, weight: .bold)
		rtlabel.textColor = #colorLiteral(red: 0.370555222, green: 0.3705646992, blue: 0.3705595732, alpha: 1)
		rtlabel.text = "Reminder"
		contentView.addSubview(rtlabel)
		rtlabel.translatesAutoresizingMaskIntoConstraints = false
		rtlabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Padding.p5).isActive = true
		rtlabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Padding.p20).isActive = true
		
		// Icon
		let icon = UIImageView(image: #imageLiteral(resourceName: "Bell").withRenderingMode(.alwaysTemplate))
		icon.tintColor = #colorLiteral(red: 0.6642242074, green: 0.6642400622, blue: 0.6642315388, alpha: 1)
		contentView.addSubview(icon)
		icon.translatesAutoresizingMaskIntoConstraints = false
		icon.widthAnchor.constraint(equalToConstant: iconSize.width).isActive = true
		icon.heightAnchor.constraint(equalToConstant: iconSize.height).isActive = true
		icon.topAnchor.constraint(equalTo: rtlabel.bottomAnchor, constant: Padding.p5).isActive = true
		icon.leadingAnchor.constraint(equalTo: rtlabel.leadingAnchor).isActive = true
		
		// Reminder label button
		reminderLabelBtn.addTarget(self, action: #selector(reminderButtonAction), for: .touchUpInside)
		contentView.addSubview(reminderLabelBtn)
		reminderLabelBtn.translatesAutoresizingMaskIntoConstraints = false
		reminderLabelBtn.centerYAnchor.constraint(equalTo: icon.centerYAnchor).isActive = true
		reminderLabelBtn.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Padding.p20).isActive = true
		reminderLabelBtn.heightAnchor.constraint(equalToConstant: iconSize.height).isActive = true
		reminderLabelBtn.isHidden = true
		
		// Segment control
		segmentControl.addTarget(self, action: #selector(segmentAction(_:)), for: .valueChanged)
		contentView.addSubview(segmentControl)
		segmentControl.translatesAutoresizingMaskIntoConstraints = false
		segmentControl.topAnchor.constraint(equalTo: reminderLabelBtn.bottomAnchor, constant: Padding.p5).isActive = true
		segmentControl.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
		segmentControl.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.5).isActive = true
		
		// Calendar view
		calendarView.selectedDate = selectDate
		contentView.addSubview(calendarView)
		calendarView.translatesAutoresizingMaskIntoConstraints = false
		calendarView.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: Padding.p2).isActive = true
		calendarView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Padding.p20).isActive = true
		calendarView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Padding.p20).isActive = true
		calendarView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Padding.p5).isActive = true
		
		// Time picker
		timePicker.addTarget(self, action: #selector(timePickerAction(_:)), for: .valueChanged)
		contentView.addSubview(timePicker)
		timePicker.translatesAutoresizingMaskIntoConstraints = false
		timePicker.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: Padding.p2).isActive = true
		timePicker.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Padding.p20).isActive = true
		timePicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Padding.p20).isActive = true
		timePicker.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Padding.p5).isActive = true
		timePicker.isHidden = true
	}
}
