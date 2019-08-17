//
//  CalenderView.swift
//  CalendarView
//
//  Created by mk mk on 3/8/19.
//  Copyright © 2019 MC2. All rights reserved.
//

import UIKit

public class CalenderView: UIView {

	// MARK: - Properties
	// - Constants
	// Weekday stack height
	private let weekdayH: CGFloat = 24
	// Default cell size
	private let defaultSize: CGFloat = 14
	
	
	// - Variables
	// Tint color
	private var calTintColor: UIColor = #colorLiteral(red: 0.6642242074, green: 0.6642400622, blue: 0.6642315388, alpha: 1)
	// Data model
	private var model = CalendarModel()
	// Selected indexpath reference
	private var selectedIndexpath: IndexPath?
	
	// - Closure
	public var selectedDate: ((Date) -> Void)?
	
	// MARK: - Views
	// Month label
	private(set) lazy var monthLabel: UILabel = {
		let lb = UILabel()
		lb.font = UIFont.systemFont(ofSize: defaultSize, weight: .semibold)
		lb.textColor = calTintColor
		return lb
	}()
	
	// Previous button
	private lazy var prevBtn: UIButton = {
		let btn = UIButton(type: .custom)
		btn.setImage(arrowImage(), for: .normal)
		btn.tintColor = calTintColor
		return btn
	}()
	
	// Next Button
	private lazy var nextBtn: UIButton = {
		let btn = UIButton(type: .custom)
		btn.setImage(arrowImage(), for: .normal)
		btn.tintColor = calTintColor
		return btn
	}()
	
	// Weekday stack
	private lazy var weekdayStack = WeekdayStack(color: calTintColor, fontSize: defaultSize)
	
	// Calendar collection
	private lazy var calendarCollection: UICollectionView = {
		// Layout
		let layout = UICollectionViewFlowLayout()
		layout.minimumLineSpacing = 0
		layout.minimumInteritemSpacing = 0
		layout.sectionInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
		layout.itemSize = CGSize(width: defaultSize, height: defaultSize)
		
		// Collection view
		let cc = UICollectionView(frame: .zero, collectionViewLayout: layout)
		return cc
	}()

	// MARK: - OVerride init
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
extension CalenderView {
	
	// Arrow image
	private func arrowImage() -> UIImage {
		let image = UIImage(named: "Arrow", in: Bundle(for: type(of: self)), compatibleWith: nil)
		return (image?.withRenderingMode(.alwaysTemplate))!
	}
	
	// Update calendar
	private func updateCalendar() {
		// Update month label
		model.updateMonthLabel(label: monthLabel)
		calendarCollection.reloadData()
	}
}

// MARK: - Actions
extension CalenderView {
	// Last month action
	@objc private func lastMonthAction() {
		model.prevMonth()
	}
	
	// Next month action
	@objc private func nextMonthAction() {
		model.nextMonth()
	}
}

// MARK: - Delegate
// MARK: - CollectionView delegate / data source
extension CalenderView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	// Number of cells
	public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return model.cellsInMonth()
	}
	
	// Configure cell
	public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		return model.configureCell(collectionView, indexPath)
	}
	
	// Select cell
	public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let cell = collectionView.cellForItem(at: indexPath) as! DateCell
		let pickedDate = cell.selectCell()
		self.selectedDate?(pickedDate)
		
		// Deselect last selected cell
		if selectedIndexpath != nil {
			if selectedIndexpath != indexPath {
				let lastSelectCell = collectionView.cellForItem(at: selectedIndexpath!) as! DateCell
				lastSelectCell.deselectCell()
			}
		}
		selectedIndexpath = indexPath
	}
	
	// Cell size
	public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let width = collectionView.frame.width / 7
		let height = width * 0.5
		return CGSize(width: width, height: height)
	}
}

// MARK: - Setup
extension CalenderView {
	private func setup() {
		// Setup UI
		setupUI()
		
		// Assign closure
		model.updateCalendar = updateCalendar
		// Update month label
		model.updateMonthLabel(label: monthLabel)
	}
	
	private func setupUI() {
//		backgroundColor = .blue
		clipsToBounds = true
		
		// Month label
		addSubview(monthLabel)
		monthLabel.translatesAutoresizingMaskIntoConstraints = false
		monthLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
		monthLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
		monthLabel.heightAnchor.constraint(equalToConstant: 28).isActive = true
		
		// Previous button
		prevBtn.addTarget(self, action: #selector(lastMonthAction), for: .touchUpInside)
		addSubview(prevBtn)
		prevBtn.translatesAutoresizingMaskIntoConstraints = false
		prevBtn.heightAnchor.constraint(equalTo: monthLabel.heightAnchor).isActive = true
		prevBtn.widthAnchor.constraint(equalTo: prevBtn.heightAnchor).isActive = true
		prevBtn.centerYAnchor.constraint(equalTo: monthLabel.centerYAnchor).isActive = true
		prevBtn.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Padding.p20).isActive = true
		
		// Next button
		nextBtn.addTarget(self, action: #selector(nextMonthAction), for: .touchUpInside)
		nextBtn.transform = nextBtn.transform.rotated(by: .pi)
		addSubview(nextBtn)
		nextBtn.translatesAutoresizingMaskIntoConstraints = false
		nextBtn.heightAnchor.constraint(equalTo: monthLabel.heightAnchor).isActive = true
		nextBtn.widthAnchor.constraint(equalTo: nextBtn.heightAnchor).isActive = true
		nextBtn.centerYAnchor.constraint(equalTo: monthLabel.centerYAnchor).isActive = true
		nextBtn.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Padding.p20).isActive = true
		
		// Weekday stack view
		addSubview(weekdayStack)
		weekdayStack.translatesAutoresizingMaskIntoConstraints = false
		weekdayStack.topAnchor.constraint(equalTo: monthLabel.bottomAnchor).isActive = true
		weekdayStack.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
		weekdayStack.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
		weekdayStack.heightAnchor.constraint(equalToConstant: weekdayH).isActive = true
		
		// Calendar collection
		calendarCollection.backgroundColor = .white
		calendarCollection.delegate = self
		calendarCollection.dataSource = self
		calendarCollection.register(DateCell.self, forCellWithReuseIdentifier: model.cellID)
		addSubview(calendarCollection)
		calendarCollection.translatesAutoresizingMaskIntoConstraints = false
		calendarCollection.topAnchor.constraint(equalTo: weekdayStack.bottomAnchor).isActive = true
		calendarCollection.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
		calendarCollection.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
		calendarCollection.heightAnchor.constraint(equalTo: calendarCollection.widthAnchor, multiplier: 6/7).isActive = true
		
		// Gestures
		// Swipe left
		let swipeL = UISwipeGestureRecognizer(target: self, action: #selector(nextMonthAction))
		swipeL.direction = .left
		calendarCollection.addGestureRecognizer(swipeL)
		
		// Swipe right
		let swipeR = UISwipeGestureRecognizer(target: self, action: #selector(lastMonthAction))
		swipeR.direction = .right
		calendarCollection.addGestureRecognizer(swipeR)
	}
}
