//
//  ListAddCell.swift
//  MemoIt
//
//  Created by mk mk on 5/7/19.
//  Copyright © 2019 MC2. All rights reserved.
//

import UIKit

private enum AddListMode {
	case title
	case color
	case reminder
}

class ListAddCell: UITableViewCell {

	// MARK:  - Properties
	// - Constant
	// Cell ID
	private let cellID = "ColorCell"
	// Cancel button height
	private let canBtnH: CGFloat = 28
	// Subview container height
	private let sbVH: CGFloat = 80
	// Corner radius
	private let cornerRadius: CGFloat = 8
	// Button group height
	private let btnGrpH: CGFloat = 20
	// Indicator size size
	private let indicatorSize: CGFloat = 16
	// Preset colors
	private let presetColors: [UIColor] = [#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1), #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1), #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1), #colorLiteral(red: 1, green: 0.4932718873, blue: 0.4739984274, alpha: 1), #colorLiteral(red: 0.6642242074, green: 0.6642400622, blue: 0.6642315388, alpha: 1)]
	
	
	// - Variables
	// Mode
	private var mode: AddListMode = .title
	// Button group
	private var btGrp = [UIButton]()
	// Current view reference
	private var currView: UIView?
	
	
	// MARK: - Views
	// Subview container
	private lazy var subViewContainer = UIView()
	
	// Title field
	lazy var titleTextView: UITextView = {
		let tv = UITextView()
		tv.backgroundColor = .clear
		tv.font = UIFont.systemFont(ofSize: 16)
		tv.tintColor = #colorLiteral(red: 0.7540688515, green: 0.7540867925, blue: 0.7540771365, alpha: 1)
		tv.textColor = #colorLiteral(red: 0.4756349325, green: 0.4756467342, blue: 0.4756404161, alpha: 1).withAlphaComponent(UIHelper.placeholderAlpha)
		tv.text = "Add task"
		tv.showsVerticalScrollIndicator = false
		tv.allowsEditingTextAttributes = true
		tv.adjustsFontForContentSizeCategory = true
		tv.autocorrectionType = .no
		tv.layer.borderColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1).cgColor
		tv.layer.borderWidth = 1.0
		return tv
	}()
	
	// Color collection view
	private lazy var colorCollection: UICollectionView = {
		let layout = UICollectionViewFlowLayout()
		layout.scrollDirection = .horizontal
		layout.minimumInteritemSpacing = 10
		layout.minimumLineSpacing = 10
		layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
		layout.itemSize = CGSize(width: 50, height: 50) 
		
		let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
		cv.backgroundColor = .white
		cv.showsHorizontalScrollIndicator = false
		cv.allowsMultipleSelection = false
		cv.dataSource = self
		cv.delegate = self
		cv.register(UICollectionViewCell.self, forCellWithReuseIdentifier: cellID)
		return cv
	}() 
	
	
	// Reminder view
	private lazy var reminderView = UIView()
	
	// Cancel button
	private lazy var cancelBtn: UIButton = {
		let btn = UIButton(type: .custom)
		btn.setImage(#imageLiteral(resourceName: "Cross44"), for: .normal)
		btn.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
		return btn
	}()
	
	// Add button
	private lazy var addBtn: UIButton = {
		let btn = UIButton(type: .custom)
		btn.setTitle("Add task", for: .normal)
		btn.setTitleColor(#colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1), for: .normal)
		btn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
		btn.addTarget(self, action: #selector(addAction), for: .touchUpInside)
		return btn
	}()
	
	// Title button
	private lazy var titleBtn: UIButton = {
		let btn = tabButton()
		btn.setTitle("Text", for: .normal)
		btn.addTarget(self, action: #selector(titleBtnAction), for: .touchUpInside)
		return btn
	}()
	
	// Color tag button
	private lazy var colorBtn: UIButton = {
		let btn = tabButton()
		btn.setTitle("Color", for: .normal)
		btn.addTarget(self, action: #selector(colorBtnAction), for: .touchUpInside)
		return btn
	}()
	
	// Reminder button
	private lazy var reminderBtn: UIButton = {
		let btn = tabButton()
		btn.setTitle("Reminder", for: .normal)
		btn.addTarget(self, action: #selector(reminderBtnAction), for: .touchUpInside)
		return btn
	}()
	
	// Color indicator group
	private lazy var colorGrp: UIStackView = {
		let grp = UIStackView()
		grp.axis = .horizontal
		grp.distribution = .fill
		grp.spacing = 5
//		grp.alignment = .leading
		return grp
	}()
	
	// Color indicator
	private lazy var colorIndicator: UIView = {
		let v = UIView()
		v.backgroundColor = .white
		v.layer.borderColor = #colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1).cgColor
		v.layer.borderWidth = 1.0
		v.layer.cornerRadius = 4.0
		return v
	}()
	
	// Reminder indicator group
	private lazy var reminderGrp: UIStackView = {
		let grp = UIStackView()
		grp.axis = .horizontal
		grp.distribution = .fill
		grp.spacing = 5
		return grp
	}()
	
	
	// Reminder indicator
	private lazy var reminderIndicator: UILabel = {
		let lb = UILabel()
		lb.textAlignment = .left
		lb.textColor = #colorLiteral(red: 0.7540688515, green: 0.7540867925, blue: 0.7540771365, alpha: 1)
		lb.font = UIFont.systemFont(ofSize: 12)
		return lb
	}()
	
	// MARK: - Custom init
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setup()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setup()
	}
	
}

// MARK: - Private function
extension ListAddCell {
	// Tab button factory
	private func tabButton() -> UIButton{
		let btn = UIButton(type: .custom)
		btn.backgroundColor = .white
		btn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
		btn.setTitleColor(#colorLiteral(red: 0.7540688515, green: 0.7540867925, blue: 0.7540771365, alpha: 1), for: .normal)
		btn.layer.cornerRadius = btnGrpH / 2.0
		btn.layer.borderColor = #colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1)
		btn.layer.borderWidth = 1.0
		return btn
	}
	
	// Indicator label
	private func indicatorLabel(text: String) -> UILabel {
		let lb = UILabel()
		lb.textAlignment = .left
		lb.textColor = #colorLiteral(red: 0.6642242074, green: 0.6642400622, blue: 0.6642315388, alpha: 1)
		lb.font = UIFont.systemFont(ofSize: 12, weight: .light)
		lb.text = text
		return lb
	}
	
	// Select button
	private func selectButton(_ button: UIButton) {
		for btn in btGrp {
			if btn === button {
				btn.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
				btn.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
				btn.layer.borderColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1).cgColor 
			}
			else {
				btn.backgroundColor = .white
				btn.setTitleColor(#colorLiteral(red: 0.7540688515, green: 0.7540867925, blue: 0.7540771365, alpha: 1), for: .normal)
				btn.layer.borderColor = #colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1).cgColor
			}
		}
	}
	
	// Check current view
	private func checkCurrV() {
		if let view = currView {
			view.removeFromSuperview()
		}
	}
	
	// Add to subContainer
	private func addToSubContainer(_ view: UIView) {
		subViewContainer.addSubview(view)
		view.topAnchor.constraint(equalTo: subViewContainer.topAnchor).isActive = true
		view.leftAnchor.constraint(equalTo: subViewContainer.leftAnchor).isActive = true
		view.rightAnchor.constraint(equalTo: subViewContainer.rightAnchor).isActive = true
		view.bottomAnchor.constraint(equalTo: subViewContainer.bottomAnchor).isActive = true
		self.currView = view
	}
}

// MARK: - Actions
extension ListAddCell {
	// Cancel action
	@objc private func cancelAction() {
		print("Cancel action")
	}
	
	// Add action
	@objc private func addAction() {
		print("Add action")
	}
	
	// Title button action
	@objc private func titleBtnAction() {
		print("title action")
		guard mode != .title else { return }
		selectButton(titleBtn)
		// Remove current view, if exist
		checkCurrV()
		
		// Add title text view
		addToSubContainer(titleTextView)

		// Highlight text view
		titleTextView.layer.borderColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1).cgColor
		titleTextView.becomeFirstResponder()
		
		// Update mode
		mode = .title
	}
	
	// Color button action
	@objc private func colorBtnAction() {
		print("color action")
		guard mode != .color else { return }
		selectButton(colorBtn)
		// Remove current view, if exist
		checkCurrV()
		
		// Unhighlight text view
		titleTextView.resignFirstResponder()
		titleTextView.layer.borderColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1).cgColor
		
		// Add color view
		addToSubContainer(colorCollection)
		
		// Update mode
		mode = .color
	} 
	
	// Reminder button action
	@objc private func reminderBtnAction() {
		print("reminder action")
		guard mode != .reminder else { return }
		selectButton(reminderBtn)
		// Remove current view, if exist
		checkCurrV()
		
		// Unhighlight text view
		titleTextView.resignFirstResponder()
		titleTextView.layer.borderColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1).cgColor
		
		// Add reminder view
		addToSubContainer(reminderView)
		
		// Update mode
		mode = .reminder
	}
}

// MARK: - UICollectionView data source / delegate
extension ListAddCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return presetColors.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath)
		let color = presetColors[indexPath.row]
		cell.backgroundColor = color
		cell.layer.cornerRadius = cornerRadius
		
		if cell.backgroundColor == #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) {
			print("====")
			cell.layer.borderColor = #colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1).cgColor
			cell.layer.borderWidth = 1.0
		}
		
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else { return CGSize(width: 50, height: 50) }
		let width = (collectionView.bounds.width - (4 * layout.minimumLineSpacing)) / 3
		let height = (collectionView.bounds.height - (3 * layout.minimumLineSpacing)) / 2
		return CGSize(width: width, height: height)
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		
	}
}


// MARK: - Setup UI
extension ListAddCell {
	private func setup() {
		selectionStyle = .none
		
		// Container
		let container = UIView()
		container.backgroundColor = .white
		container.layer.cornerRadius = cornerRadius
		container.layer.shadowColor = #colorLiteral(red: 0.2605174184, green: 0.2605243921, blue: 0.260520637, alpha: 1)
		container.layer.shadowOpacity = 0.3
		container.layer.shadowRadius = 2.0
		container.layer.shadowOffset = CGSize.zero
		container.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(container)
		container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Padding.p5).isActive = true
		container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Padding.p5).isActive = true
		container.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: Padding.p10).isActive = true
		container.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -Padding.p10).isActive = true
		
		// Title
		let titleLabel = UILabel()
		titleLabel.textAlignment = .left
		titleLabel.textColor = UIHelper.defaultTint
		titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .regular)
		titleLabel.text = "Task"
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		container.addSubview(titleLabel)
		titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: Padding.p5).isActive = true
		titleLabel.leftAnchor.constraint(equalTo: container.leftAnchor, constant: Padding.p20).isActive = true
		
		// Cancel button
		cancelBtn.translatesAutoresizingMaskIntoConstraints = false
		container.addSubview(cancelBtn)
		cancelBtn.widthAnchor.constraint(equalToConstant: canBtnH).isActive = true
		cancelBtn.heightAnchor.constraint(equalToConstant: canBtnH).isActive = true
		cancelBtn.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -Padding.p20).isActive = true
		cancelBtn.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor).isActive = true
		
		// Separator
		let sep = UIView()
		sep.isUserInteractionEnabled = false
		sep.backgroundColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)
		sep.translatesAutoresizingMaskIntoConstraints = false
		container.addSubview(sep)
		sep.heightAnchor.constraint(equalToConstant: 1).isActive = true
		sep.leftAnchor.constraint(equalTo: container.leftAnchor, constant: Padding.p20).isActive = true
		sep.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -Padding.p20).isActive = true
		sep.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Padding.p2).isActive = true
		
		// Button group
		let btnGrp = UIStackView()
		btnGrp.axis = .horizontal
		btnGrp.distribution = .fillEqually
		btnGrp.alignment = .center
		btnGrp.spacing = 10.0
		btnGrp.translatesAutoresizingMaskIntoConstraints = false
		container.addSubview(btnGrp)
		btnGrp.topAnchor.constraint(equalTo: sep.bottomAnchor, constant: Padding.p5).isActive = true
		btnGrp.leftAnchor.constraint(equalTo: container.leftAnchor, constant: Padding.p20).isActive = true
		btnGrp.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -Padding.p20).isActive = true
		btnGrp.heightAnchor.constraint(equalToConstant: btnGrpH).isActive = true
		
		// Title button
		btnGrp.addArrangedSubview(titleBtn)
		
		// Color button
		btnGrp.addArrangedSubview(colorBtn)
		
		// Reminder button
		btnGrp.addArrangedSubview(reminderBtn)
		
		// Add buttons to button array
		btGrp.append(titleBtn)
		btGrp.append(colorBtn)
		btGrp.append(reminderBtn)
		
		// Subview container
		subViewContainer.translatesAutoresizingMaskIntoConstraints = false
		container.addSubview(subViewContainer)
		subViewContainer.topAnchor.constraint(equalTo: btnGrp.bottomAnchor, constant: Padding.p5).isActive = true
		subViewContainer.leftAnchor.constraint(equalTo: container.leftAnchor, constant: Padding.p20).isActive = true
		subViewContainer.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -Padding.p20).isActive = true
		subViewContainer.heightAnchor.constraint(equalToConstant: sbVH).isActive = true
		
		// Add button
		addBtn.translatesAutoresizingMaskIntoConstraints = false
		container.addSubview(addBtn)
		addBtn.topAnchor.constraint(equalTo: subViewContainer.bottomAnchor, constant: Padding.p5).isActive = true
		addBtn.rightAnchor.constraint(equalTo: subViewContainer.rightAnchor, constant: -Padding.p10).isActive = true
		
		// Color group
		colorGrp.translatesAutoresizingMaskIntoConstraints = false
		container.addSubview(colorGrp)
		colorGrp.topAnchor.constraint(lessThanOrEqualTo: subViewContainer.bottomAnchor, constant: Padding.p5).isActive = true
		colorGrp.leftAnchor.constraint(equalTo: subViewContainer.leftAnchor).isActive = true
		colorGrp.rightAnchor.constraint(lessThanOrEqualTo: addBtn.leftAnchor, constant: -Padding.p40).isActive = true
		colorGrp.heightAnchor.constraint(equalToConstant: indicatorSize).isActive = true
		
		// Color tag icon
		let colorIcon = UIImageView(image: #imageLiteral(resourceName: "Tag").withRenderingMode(.alwaysTemplate))
		colorIcon.tintColor = #colorLiteral(red: 0.6642242074, green: 0.6642400622, blue: 0.6642315388, alpha: 1)
		colorIcon.translatesAutoresizingMaskIntoConstraints = false
		colorGrp.addArrangedSubview(colorIcon)
		colorIcon.widthAnchor.constraint(equalToConstant: indicatorSize).isActive = true
		colorIcon.heightAnchor.constraint(equalToConstant: indicatorSize).isActive = true		
		
		// Color tag label
		let colorLabel = indicatorLabel(text: ":")
		colorGrp.addArrangedSubview(colorLabel)
		
		// Color tag image
		colorIndicator.translatesAutoresizingMaskIntoConstraints = false
		colorGrp.addArrangedSubview(colorIndicator)
		colorIndicator.widthAnchor.constraint(equalToConstant: indicatorSize).isActive = true
		colorIndicator.heightAnchor.constraint(equalToConstant: indicatorSize).isActive = true
		
		// Reminder group
		reminderGrp.translatesAutoresizingMaskIntoConstraints = false
		container.addSubview(reminderGrp)
		reminderGrp.topAnchor.constraint(equalTo: colorGrp.bottomAnchor, constant: Padding.p5).isActive = true
		reminderGrp.leftAnchor.constraint(equalTo: colorGrp.leftAnchor).isActive = true
		reminderGrp.rightAnchor.constraint(lessThanOrEqualTo: addBtn.leftAnchor, constant: -Padding.p20).isActive = true
		reminderGrp.heightAnchor.constraint(equalToConstant: indicatorSize).isActive = true
		
		// Reminder tag icon
		let reminderIcon = UIImageView(image: #imageLiteral(resourceName: "Bell").withRenderingMode(.alwaysTemplate))
		reminderIcon.tintColor = #colorLiteral(red: 0.6642242074, green: 0.6642400622, blue: 0.6642315388, alpha: 1)
		reminderIcon.translatesAutoresizingMaskIntoConstraints = false
		reminderGrp.addArrangedSubview(reminderIcon)
		reminderIcon.widthAnchor.constraint(equalToConstant: indicatorSize).isActive = true
		reminderIcon.heightAnchor.constraint(equalToConstant: indicatorSize).isActive = true		
		
		
		// Reminder tag label
		let reminderLabel = indicatorLabel(text: ":")
		reminderLabel.translatesAutoresizingMaskIntoConstraints = false
		reminderGrp.addArrangedSubview(reminderLabel)
		
		
		// Reminder  tag date label
		reminderIndicator.text = "9999/99/99 33:33"
		reminderIndicator.translatesAutoresizingMaskIntoConstraints = false
		reminderGrp.addArrangedSubview(reminderIndicator)
		
		
		
		// Disable subview auto resizing mask
		titleTextView.translatesAutoresizingMaskIntoConstraints = false
		colorCollection.translatesAutoresizingMaskIntoConstraints = false
		reminderView.translatesAutoresizingMaskIntoConstraints = false
		
		// Add titleText View
		addToSubContainer(titleTextView)
		
		// Select title button
		selectButton(titleBtn)
		titleTextView.layer.borderColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1).cgColor
		
		
		
		
		
		
		
		reminderView.backgroundColor = #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1)
		
	}
}
