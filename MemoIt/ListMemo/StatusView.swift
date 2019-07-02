//
//  StatusView.swift
//  MemoIt
//
//  Created by mk mk on 30/6/19.
//  Copyright © 2019 MC2. All rights reserved.
//

import UIKit

class StatusView: UIView {

	// MARK: - Properties
	
	// - Variables
	private var stateTtile: String = ""
	
	// MARK: - Views
	// Title label
	private lazy var titleLabel: UILabel = {
		let lb = UILabel()
		lb.textColor = UIHelper.defaultTint
		lb.textAlignment = .center
		lb.font = UIFont.systemFont(ofSize: 12, weight: .light)
		return lb
	}()
	
	// State label
	private lazy var stateLabel: UILabel = {
		let lb = UILabel()
		lb.textColor = UIHelper.defaultTint
		lb.textAlignment = .center
		lb.font = UIFont.systemFont(ofSize: 24)
		lb.text = "100%"
		return lb
	}()
	
	// MARK: - Convenience init
	convenience init(title: String) {
		self.init()
		self.stateTtile = title
		setup()
	}
	
}

// MARK: - Public function
extension StatusView { 
	func updateState(stateData: String) {
		stateLabel.text = stateData
	}
}

// MARK: - Setup UI
extension StatusView {
	private func setup() {
		// Title label
		titleLabel.text = stateTtile
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		addSubview(titleLabel)
		titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: Padding.p5).isActive = true
		titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
		
		// state label
		stateLabel.translatesAutoresizingMaskIntoConstraints = false
		addSubview(stateLabel)
		stateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Padding.p10).isActive = true
		stateLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
	}
}
