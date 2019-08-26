//
//  AddTaskView.swift
//  MemoIt
//
//  Created by mk mk on 21/7/19.
//  Copyright © 2019 MC2. All rights reserved.
//

import UIKit

class AddTaskView: UIView {

	// MARK: - Properties
	// - Constants
	// Font size
	private let font = UIFont.systemFont(ofSize: 20)
	// Bell button size
	private let bellSize: CGFloat = 30
	// Color button size
	private let colorSize: CGFloat = 24
	// Text field margin
	private let txMargin: CGFloat = 8
	// Input stack height
	private let inputStackH: CGFloat = 34
	// Reminder label button height
	private let rmlbtnH: CGFloat = 24
	// Input view width
	private let inputViewW: CGFloat = UIScreen.main.bounds.width
	
	// Color stack hieght
	private let colorStackH: CGFloat = 16
	// Theme color
	private let themeColor: UIColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 0.5)
	// Task color
	private let taskColor: [UIColor] = [#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1), #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1), #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1), #colorLiteral(red: 1, green: 0.4932718873, blue: 0.4739984274, alpha: 1), #colorLiteral(red: 0.6642242074, green: 0.6642400622, blue: 0.6642315388, alpha: 1)]
	
	// - Variables
	// Reminder label button height constraint
	private var rmlbHCst = NSLayoutConstraint()
	// Reminder time
	private var reminderTime: Date?
	
	// - Closure
	var newTask: ((ListItemModel) -> Void)?
	
	
	// MARK: - Views
	// Main button
	private lazy var mainBtn: UIButton = {
		let btn = UIButton(type: .custom)
		btn.titleLabel?.font = font
		btn.setTitleColor(#colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1), for: .normal)
		btn.setTitle("Add new task", for: .normal)
		return btn
	}()
	
	// Input stack
	private lazy var inputStack: UIStackView = {
		let st = UIStackView()
		st.axis = .horizontal
		st.alignment = .center
		st.distribution = .fill
		st.spacing = 20
		return st
	}()
	
	// Color button
	private lazy var colorBtn: UIButton = {
		let btn = UIButton(type: .custom)
		btn.backgroundColor = .white
		btn.layer.cornerRadius = 8.0
		btn.layer.borderWidth = 1.2
		btn.layer.borderColor = themeColor.cgColor
		return btn
	}()
	
	// Reminder button
	private lazy var reminderBtn: UIButton = {
		let btn = UIButton(type: .custom)
		btn.setImage(#imageLiteral(resourceName: "Bell").withRenderingMode(.alwaysTemplate), for: .normal)
		btn.tintColor = themeColor
		return btn
	}()
	
	// Text field
	private lazy var textField: UITextField = {
		let tf = UITextField()
		tf.backgroundColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 0.5)
		tf.font = font
		tf.textColor = #colorLiteral(red: 0.6642242074, green: 0.6642400622, blue: 0.6642315388, alpha: 1)
		tf.tintColor = themeColor
		tf.returnKeyType = .done
		tf.attributedPlaceholder = NSAttributedString(string: "Add new task", 
												   attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)])
		tf.allowsEditingTextAttributes = false
		tf.autocorrectionType = .default

		tf.layer.cornerRadius = 8.0
		tf.layer.borderWidth = 1.0
		tf.layer.borderColor = themeColor.cgColor
		
		let letfMargin = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
		tf.leftView = letfMargin
		tf.leftViewMode = .always
		
		return tf
	}()
	
	// Reminder label button
	private lazy var reminderLabelBtn: UIButton = {
		let btn = UIButton(type: .custom)
		btn.backgroundColor = .white
		btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
		btn.setTitleColor(#colorLiteral(red: 0.4425499737, green: 0.7958466411, blue: 0.945319593, alpha: 1), for: .normal)
		btn.setImage(#imageLiteral(resourceName: "Cross44").withRenderingMode(.alwaysTemplate), for: .normal)
		btn.imageView?.contentMode = .scaleAspectFit
		btn.tintColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
		btn.semanticContentAttribute = .forceRightToLeft
		btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: -10)
				
		btn.layer.cornerRadius = 6.0
		btn.layer.borderWidth = 1.0
		btn.layer.borderColor = #colorLiteral(red: 0.4620226622, green: 0.8382837176, blue: 1, alpha: 0.5).cgColor
		return btn
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

// MARK: - Public function
extension AddTaskView {
	// Edit mode
	func edit() {
		inputStack.isHidden = false
		mainBtn.isHidden = true
	}
	
	// Idle mode
	func idle() {
		reminderLabelBtn.isHidden = true
		rmlbHCst.constant = 0
		self.layoutIfNeeded()
		
		textField.text = ""
		reminderTime = nil
		colorBtn.backgroundColor = .white
		colorBtn.layer.borderWidth = 1.0
		mainBtn.isHidden = false
		inputStack.isHidden = true
	}
}

// MARK: - Private function
extension AddTaskView {	
	// End edit
	private func endEdit() {
		if let text = textField.text, 
			text.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
			// Add new task
			var newTask = ListItemModel(title: text)
			newTask.color = colorBtn.backgroundColor!
			newTask.reminder = reminderTime
			self.newTask?(newTask)
		}
		
		textField.resignFirstResponder()
		idle()
	}
	
	// MARK: - Closure functions
	// Select color
	private func updateColor(color: UIColor) {
		// Update color button background color
		colorBtn.backgroundColor = color
		// Show / hide border color
		colorBtn.layer.borderWidth = ((color == #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)) ? 1.0 : 0.0)
		
		// Switch back to keyboard
		textField.inputView = nil
		textField.reloadInputViews()
	}
	
	// Add Reminder label
	private func addReminderLabel() {
		// Show reminder label button
		reminderLabelBtn.isHidden = false
		// Update constraint
		rmlbHCst.constant = rmlbtnH
		UIView.animate(withDuration: 0.2) { 
			self.layoutIfNeeded()
		}
	}
	
	// Update reminder time
	private func updateReminderTime(date: Date) {
		if reminderLabelBtn.isHidden {
			addReminderLabel()
		}
		
		// Formatter
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy/MM/dd  HH:mm"
		reminderLabelBtn.setTitle(formatter.string(from: date), for: .normal)
		
		// Set reminder time
		self.reminderTime = date
	}
	
	// Back to keyboard
	private func backToKeyboard() {
		textField.inputView = nil
		textField.reloadInputViews()
	}
}

// MARK: - Actions
extension AddTaskView {
	// Reminder action
	@objc private func reminderAction() {
		let datePicker = DatePickerView(frame: CGRect(x: 0, y: 0, width: inputViewW, height: 320))
		datePicker.pickedDate = updateReminderTime
		datePicker.backToKeyboard = backToKeyboard
		textField.inputView = datePicker
		textField.reloadInputViews()
	}
	
	// Color action
	@objc private func colorAction(_ sender: UIButton) {
		let colorPicker = ColorPickerView(frame: CGRect(x: 0, y: 0, width: inputViewW, height: 144))
		colorPicker.selectColor = updateColor
		colorPicker.backToKeyboard = backToKeyboard
		textField.inputView = colorPicker
		textField.reloadInputViews()
	}
	
	// Start editing
	@objc private func startEditAction() {
		textField.becomeFirstResponder()
		edit()
	}
	
	// Hide reminder label button
	@objc private func hideReminderLabel() {
		// Update constraint
		rmlbHCst.constant = 0
		UIView.animate(withDuration: 0.2, 
					   animations: { 
						self.layoutIfNeeded()
		}) { (finished) in
			if finished {
				self.reminderLabelBtn.isHidden = true
				// Switch back to keyboard
				self.textField.inputView = nil
				self.textField.reloadInputViews()
			}
		}
		
		// Reset reminder time
		self.reminderTime = nil
	}
}

// MARK: UITextField delegate
extension AddTaskView: UITextFieldDelegate {
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		endEdit()
		return true
	}
}

// MARK: - Setup UI
extension AddTaskView {
	private func setup() {
		
//		backgroundColor = .orange
		
		// Separator
		let sep = UIView()
		sep.backgroundColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 0.2)
		sep.translatesAutoresizingMaskIntoConstraints = false
		addSubview(sep)
		sep.heightAnchor.constraint(equalToConstant: 1).isActive = true
		sep.topAnchor.constraint(equalTo: topAnchor).isActive = true
		sep.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
		sep.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
		
		// Main button
		mainBtn.addTarget(self, action: #selector(startEditAction), for: .touchUpInside)
		addSubview(mainBtn)
		mainBtn.translatesAutoresizingMaskIntoConstraints = false
		mainBtn.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
		mainBtn.topAnchor.constraint(equalTo: topAnchor, constant: Padding.p10).isActive = true
		
		// Input stack
		addSubview(inputStack)
		inputStack.translatesAutoresizingMaskIntoConstraints = false
		inputStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Padding.p20).isActive = true
		inputStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Padding.p20).isActive = true
		inputStack.topAnchor.constraint(equalTo: topAnchor, constant: txMargin).isActive = true
		inputStack.heightAnchor.constraint(equalToConstant: inputStackH).isActive = true
		inputStack.isHidden = true
		
		// Color button
		colorBtn.addTarget(self, action: #selector(colorAction(_:)), for: .touchUpInside)
		inputStack.addArrangedSubview(colorBtn)
		colorBtn.translatesAutoresizingMaskIntoConstraints = false
		colorBtn.widthAnchor.constraint(equalToConstant: colorSize).isActive = true
		colorBtn.heightAnchor.constraint(equalTo: colorBtn.widthAnchor).isActive = true

		// Reminder button
		reminderBtn.addTarget(self, action: #selector(reminderAction), for: .touchUpInside)
		inputStack.addArrangedSubview(reminderBtn)
		reminderBtn.translatesAutoresizingMaskIntoConstraints = false
		reminderBtn.heightAnchor.constraint(equalToConstant: bellSize).isActive = true
		reminderBtn.widthAnchor.constraint(equalTo: reminderBtn.heightAnchor).isActive = true

		// Text field
		textField.delegate = self
		inputStack.addArrangedSubview(textField)
		textField.translatesAutoresizingMaskIntoConstraints = false
		textField.heightAnchor.constraint(equalToConstant: inputStackH).isActive = true
		
		// Reminder label button
		reminderLabelBtn.addTarget(self, action: #selector(hideReminderLabel), for: .touchUpInside)
		addSubview(reminderLabelBtn)
		reminderLabelBtn.translatesAutoresizingMaskIntoConstraints = false
		reminderLabelBtn.topAnchor.constraint(equalTo: inputStack.bottomAnchor, constant: Padding.p5).isActive = true
		reminderLabelBtn.leadingAnchor.constraint(equalTo: inputStack.leadingAnchor).isActive = true
		rmlbHCst = reminderLabelBtn.heightAnchor.constraint(equalToConstant: 0)
		rmlbHCst.isActive = true
		reminderLabelBtn.isHidden = true
		bottomAnchor.constraint(equalTo: reminderLabelBtn.bottomAnchor, constant: txMargin).isActive = true
	}
}
