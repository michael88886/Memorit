//
//  HomeCell.swift
//  MemoIt
//
//  Created by mk mk on 29/6/19.
//  Copyright © 2019 MC2. All rights reserved.
//

import UIKit

class HomeCell: UITableViewCell {

	// MARK: - Properties
	// - Constants
	// Corner radius
	let cornerRadius: CGFloat = 8.0
	
	// MARK: - Views
	// Container
	private(set) lazy var container = UIView()
	// Title view
	private(set) lazy var titleView = HomeCellTitleView()
	
	
	// MARK: - Custom init
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setup()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setup()
	}
	
	// MARK: - Override functions
	override func prepareForReuse() {
		super.prepareForReuse()
		titleView.resetTitleView()
	}
	
	func feedCell(model: MemoModel) {
		titleView.updateTitleView(data: model)
	}
}


// MARK: - Setup Cell
extension HomeCell {
	@objc func setup() {
		
		self.selectionStyle = .none
		
		// Shadow view
		let shadowView = UIView()
//		shadowView.backgroundColor = .white
		shadowView.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).cgColor
		shadowView.layer.shadowOpacity = 0.2
		shadowView.layer.shadowOffset = CGSize.zero
		shadowView.layer.shadowRadius = 4.0
		shadowView.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(shadowView)
		shadowView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Padding.p10).isActive = true
		shadowView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: Padding.p10).isActive = true
		shadowView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -Padding.p10).isActive = true
		shadowView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Padding.p10).isActive = true
		
		// Container
		container.backgroundColor = .white
		container.layer.cornerRadius = cornerRadius
		container.clipsToBounds = true
		container.translatesAutoresizingMaskIntoConstraints = false
		shadowView.addSubview(container)
		container.topAnchor.constraint(equalTo: shadowView.topAnchor).isActive = true
		container.leftAnchor.constraint(equalTo: shadowView.leftAnchor).isActive = true
		container.rightAnchor.constraint(equalTo: shadowView.rightAnchor).isActive = true
		container.bottomAnchor.constraint(equalTo: shadowView.bottomAnchor).isActive = true
		
		// Title view
		titleView.translatesAutoresizingMaskIntoConstraints = false
		container.addSubview(titleView)
		titleView.topAnchor.constraint(equalTo: container.topAnchor).isActive = true
		titleView.leftAnchor.constraint(equalTo: container.leftAnchor).isActive = true
		titleView.rightAnchor.constraint(equalTo: container.rightAnchor).isActive = true
	}
}
