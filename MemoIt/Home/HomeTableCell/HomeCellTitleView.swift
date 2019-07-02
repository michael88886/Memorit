//
//  HomeCellTitleView.swift
//  MemoIt
//
//  Created by mk mk on 27/6/19.
//  Copyright © 2019 MC2. All rights reserved.
//

import UIKit

class HomeCellTitleView: UIView {

	// MARK: - Properties
	// - Constants
	// Icon size
	private let iconSize: CGFloat = 24
	
	// MARK: - Views
	// Icon
	lazy var iconView = UIImageView()
	// Title label
	lazy var titleLabel = UIHelper.label(font: UIFont.systemFont(ofSize: 20, weight: .regular), textColor: UIHelper.defaultTint)
	// Date label
	lazy var dateLabel = UIHelper.label(font: UIFont.systemFont(ofSize: 12), textColor: #colorLiteral(red: 0.4756349325, green: 0.4756467342, blue: 0.4756404161, alpha: 1))
	// Time label
	lazy var timeLabel = UIHelper.label(font: UIFont.systemFont(ofSize: 12), textColor: #colorLiteral(red: 0.4756349325, green: 0.4756467342, blue: 0.4756404161, alpha: 1))
	
	// MARK: - Custom init
	override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setup()
	}
	
	// MARK: - Update title view
	func updateTitleView(data: MemoModel) {
		titleLabel.text = data.title
		dateLabel.text = CalendarHelper.dateToString(date: data.date, format: .memoTime)
		timeLabel.text = CalendarHelper.dateToString(date: data.date, format: .hourMinute)
		
		if let type = MemoType(rawValue: data.type.rawValue) {
			switch type {
			case .attach:
				iconView.image = #imageLiteral(resourceName: "Attach44").withRenderingMode(.alwaysTemplate)
			case .todo:
				iconView.image = #imageLiteral(resourceName: "CheckBox44").withRenderingMode(.alwaysTemplate)
			case .voice:
				iconView.image = #imageLiteral(resourceName: "SoundWave44").withRenderingMode(.alwaysTemplate)
			}
		}
		
		
//		layoutIfNeeded()
	}
	
	func resetTitleView() {
		titleLabel.text = ""
		dateLabel.text = ""
		timeLabel.text = ""
	}
}


// MARK: - Setup View
extension HomeCellTitleView {
	private func setup() {
		// Date label
		dateLabel.translatesAutoresizingMaskIntoConstraints = false
		addSubview(dateLabel)
		dateLabel.topAnchor.constraint(equalTo: topAnchor, constant: Padding.p5).isActive = true
		dateLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -Padding.p20).isActive = true
		
		// Time label
		timeLabel.translatesAutoresizingMaskIntoConstraints = false
		addSubview(timeLabel)
		timeLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor).isActive = true
		timeLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -Padding.p20).isActive = true
		
		// Icon
		iconView.tintColor = UIHelper.defaultTint
		iconView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(iconView)
		iconView.widthAnchor.constraint(equalToConstant: iconSize).isActive = true
		iconView.heightAnchor.constraint(equalToConstant: iconSize).isActive = true
		iconView.leftAnchor.constraint(equalTo: leftAnchor, constant: Padding.p10).isActive = true
		iconView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
		
		// Title label
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		addSubview(titleLabel)
		titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: Padding.p5).isActive = true
		titleLabel.leftAnchor.constraint(equalTo: iconView.rightAnchor, constant: Padding.p10).isActive = true
		titleLabel.rightAnchor.constraint(lessThanOrEqualTo: dateLabel.leftAnchor, constant: -Padding.p20).isActive = true
		
		// Self sizing
		bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Padding.p5).isActive = true
		
		// Separator
		let sep = UIHelper.separator(withColor: #colorLiteral(red: 0.8374213576, green: 0.8374213576, blue: 0.8374213576, alpha: 1))
		sep.translatesAutoresizingMaskIntoConstraints = false
		addSubview(sep)
		sep.heightAnchor.constraint(equalToConstant: 1).isActive = true
		sep.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.9).isActive = true
		sep.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
		sep.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
	}
}
