//
//  FunctionView.swift
//  MemoIt
//
//  Created by mk mk on 7/6/19.
//  Copyright © 2019 MC2. All rights reserved.
//

import UIKit

class FunctionView: UIView {

	// MARK: - Properties
	// - Constant
	// Button tint size
	private let btnTint: UIColor = #colorLiteral(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)
	// Center button width
	private let ctrBtnW: CGFloat = 144
	// Center button height
	private let ctrBtnH: CGFloat = 56
	// Button size
	private let btnSize: CGFloat = 40
	// Large button size
	private let lrgBtnSize: CGFloat = 60
	// Expand flag
	private(set) var isExpanded = false
	// Expand height
	let expandH: CGFloat = 144
	
	// - Add voice button constraints
	// Origin constriant
	private var addVoiceOriginX = NSLayoutConstraint()
	private var addVoiceOriginY = NSLayoutConstraint()
	// Destination constriant
	private var addVoiceDestX = NSLayoutConstraint()
	private var addVoiceDestY = NSLayoutConstraint()
	
	// - Add check box button constraints
	// Origin constriant
	private var addListOriginX = NSLayoutConstraint()
	private var addListOriginY = NSLayoutConstraint()
	// Destination constriant
	private var addListDestX = NSLayoutConstraint()
	private var addListDestY = NSLayoutConstraint()
	
	
	// MARK: - Views
	// Add button
	private lazy var addBtn: UIButton = {
		let btn = UIHelper.button(icon: #imageLiteral(resourceName: "Plus44"), tint: btnTint)
		btn.addTarget(self, action: #selector(centerAction), for: .touchUpInside)
		btn.backgroundColor = #colorLiteral(red: 1, green: 0.8039215686, blue: 0, alpha: 1)
		btn.layer.cornerRadius = ctrBtnW / 2.0
		// Drop shadow
		btn.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).cgColor
		btn.layer.shadowOpacity = 0.2
		btn.layer.shadowRadius = 2.0
		btn.layer.shadowOffset = CGSize.zero
		return btn
	}()
	
	// Setting button
	private lazy var menuBtn: UIButton = {
		let btn = UIHelper.button(icon: #imageLiteral(resourceName: "Menu44"), tint: btnTint)
		btn.addTarget(self, action: #selector(menuAction), for: .touchUpInside)
		return btn
	}()
	
	// Edit button
	private lazy var moreBtn: UIButton = {
		let btn = UIHelper.button(icon: #imageLiteral(resourceName: "Dots44"), tint: .btnTint)
		btn.addTarget(self, action: #selector(moreAction), for: .touchUpInside)
		return btn
	}()
	
	// Voice memo button
	private lazy var voiceBtn: UIButton = {
		let btn = scaledButton(icon: #imageLiteral(resourceName: "SoundWave44"), tint: #colorLiteral(red: 1, green: 0.5725490196, blue: 0.5607843137, alpha: 1))
		btn.addTarget(self, action: #selector(addVoiceAction), for: .touchUpInside)
		return btn
	}()
	
	// Todo button
	private lazy var todoBtn: UIButton = {
		let btn = scaledButton(icon: #imageLiteral(resourceName: "CheckBox44"), tint: #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1))
		btn.addTarget(self, action: #selector(addTodoAction), for: .touchUpInside)
		return btn
	}()
	
	// Memo button
	private lazy var memoBtn: UIButton = {
		let btn = scaledButton(icon: #imageLiteral(resourceName: "Memo44"), tint: #colorLiteral(red: 1, green: 0.8039215686, blue: 0, alpha: 1))
		btn.addTarget(self, action: #selector(addMemoAction), for: .touchUpInside)
		return btn
	}()
	
	
	// MARK: - Custom init
	override init(frame: CGRect) {
		super.init(frame: frame)
		loadView()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		loadView()
	}

}

// MARK: - Publice functions
extension FunctionView {
	func resetOption(animated: Bool) {
		isExpanded = false
		delegate?.hideOption(animated: animated)
	}
	
	func showOption() {
		// Add memo button
		addMemoBtn.alpha = 0
		addMemoBtn.isHidden = false
		
		// Add voice button
		addVoiceBtn.alpha = 0
		addVoiceBtn.isHidden = false
		addVoiceOriginX.isActive = false
		addVoiceOriginY.isActive = false
		addVoiceDestX.isActive = true
		addVoiceDestY.isActive = true
		
		// Add list button
		addListBtn.alpha = 0
		addListBtn.isHidden = false
		addListOriginX.isActive = false
		addListOriginY.isActive = false
		addListDestX.isActive = true
		addListDestY.isActive = true
	}
	
	func hideOption() {
		// Add memo button
		addMemoBtn.alpha = 1
		
		// Add voice button
		addVoiceBtn.alpha = 1
		addVoiceDestX.isActive = false
		addVoiceDestY.isActive = false
		addVoiceOriginX.isActive = true
		addVoiceOriginY.isActive = true
		
		// Add list button
		addListBtn.alpha = 1
		addListDestX.isActive = false
		addListDestY.isActive = false
		addListOriginX.isActive = true
		addListOriginY.isActive = true
	}
	
	func showOptionTransition() {
		// Center button
		centerBtn.backgroundColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
		centerBtn.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 4)
		
		// Add memo button
		addMemoBtn.transform = CGAffineTransform(scaleX: 1, y: 1)
		addMemoBtn.alpha = 1
		
		// Add voice button
		addVoiceBtn.transform = CGAffineTransform(scaleX: 1, y: 1)
		addVoiceBtn.alpha = 1
		
		// Add list buttion
		addListBtn.transform = CGAffineTransform(scaleX: 1, y: 1)
		addListBtn.alpha = 1
	}
	
	func hideOptionTransition() {
		// Center button
		centerBtn.backgroundColor = btnTint
		centerBtn.transform = CGAffineTransform(rotationAngle: 0)
		
		// Add memo button
		addMemoBtn.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
		addMemoBtn.alpha = 0
		
		// Add voice button
		addVoiceBtn.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
		addVoiceBtn.alpha = 0
		
		// Add list buttion
		addListBtn.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
		addListBtn.alpha = 0
	}
	
	func showCompleted() {
		// Disable left / right buttons
		leftBtn.isEnabled = false
		rightBtn.isEnabled = false
	}
	
	func hideCompleted(){
		// Enable left / right buttons
		leftBtn.isEnabled = true
		rightBtn.isEnabled = true
		
		// Hide function buttons
		addMemoBtn.isHidden = true
		addVoiceBtn.isHidden = true
		addListBtn.isHidden = true
	}
}

// MARK: - Actions
extension FunctionView {
	// Center action
	@objc private func centerAction() {
		
	}
	
	// Menu action
	@objc private func menuAction() {
		
	}
	
	// More action
	@objc private func moreAction() {
		
	}
	
	// Add voice action
	@objc private func addVoiceAction() {
		
	}
	
	// Add todo action
	@objc private func addTodoAction() {
		
	}
	
	// Add memo action
	@objc private func addMemoAction() {
		
	}
	
}

// MARK: - Private functions
extension FunctionView {
	// Setup view
	private func loadView() {
		// Background color
		backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
		clipsToBounds = false
		
		// Shadow
		layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).cgColor
		layer.shadowOpacity = 0.1
		layer.shadowRadius = 1.0
		layer.shadowOffset = CGSize(width: 0, height: -1)
		
		// Center button
		centerBtn.translatesAutoresizingMaskIntoConstraints = false
		addSubview(centerBtn)
		centerBtn.widthAnchor.constraint(equalToConstant: ctrBtnSize).isActive = true
		centerBtn.heightAnchor.constraint(equalToConstant: ctrBtnSize).isActive = true
		centerBtn.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
		centerBtn.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -UIHelper.Padding.p5).isActive = true
		
		// Left button
		leftBtn.translatesAutoresizingMaskIntoConstraints = false
		addSubview(leftBtn)
		leftBtn.widthAnchor.constraint(equalToConstant: btnSize).isActive = true
		leftBtn.heightAnchor.constraint(equalToConstant: btnSize).isActive = true
		leftBtn.leftAnchor.constraint(equalTo: leftAnchor, constant: UIHelper.Padding.p40).isActive = true
		leftBtn.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
		
		// Right button
		rightBtn.translatesAutoresizingMaskIntoConstraints = false
		addSubview(rightBtn)
		rightBtn.widthAnchor.constraint(equalToConstant: btnSize).isActive = true
		rightBtn.heightAnchor.constraint(equalToConstant: btnSize).isActive = true
		rightBtn.rightAnchor.constraint(equalTo: rightAnchor, constant: -UIHelper.Padding.p40).isActive = true
		rightBtn.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
		
		
		// Add memo button
		addMemoBtn.translatesAutoresizingMaskIntoConstraints = false
		//        addMemoBtn.backgroundColor = #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)
		insertSubview(addMemoBtn, belowSubview: centerBtn)
		addMemoBtn.widthAnchor.constraint(equalToConstant: lrgBtnSize).isActive = true
		addMemoBtn.heightAnchor.constraint(equalToConstant: lrgBtnSize).isActive = true
		addMemoBtn.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
		addMemoBtn.topAnchor.constraint(equalTo: topAnchor, constant: UIHelper.Padding.p20).isActive = true
		addMemoBtn.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
		addMemoBtn.isHidden = true
		
		// Add voice button
		addVoiceBtn.translatesAutoresizingMaskIntoConstraints = false
		//        addVoiceBtn.backgroundColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
		insertSubview(addVoiceBtn, belowSubview: centerBtn)
		addVoiceBtn.widthAnchor.constraint(equalToConstant: lrgBtnSize).isActive = true
		addVoiceBtn.heightAnchor.constraint(equalToConstant: lrgBtnSize).isActive = true
		addVoiceOriginX = addVoiceBtn.centerXAnchor.constraint(equalTo: centerBtn.centerXAnchor)
		addVoiceOriginY = addVoiceBtn.centerYAnchor.constraint(equalTo: centerBtn.centerYAnchor)
		addVoiceDestX = addVoiceBtn.leftAnchor.constraint(equalTo: leftBtn.leftAnchor)
		addVoiceDestY = addVoiceBtn.centerYAnchor.constraint(equalTo: addMemoBtn.bottomAnchor)
		addVoiceOriginX.isActive = true
		addVoiceOriginY.isActive = true
		addVoiceDestX.isActive = false
		addVoiceDestY.isActive = false
		addVoiceBtn.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
		addVoiceBtn.isHidden = true
		
		// Add check list button
		addListBtn.translatesAutoresizingMaskIntoConstraints = false
		//        addListBtn.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
		insertSubview(addListBtn, belowSubview: centerBtn)
		addListBtn.widthAnchor.constraint(equalToConstant: lrgBtnSize).isActive = true
		addListBtn.heightAnchor.constraint(equalToConstant: lrgBtnSize).isActive = true
		addListOriginX = addListBtn.centerXAnchor.constraint(equalTo: centerBtn.centerXAnchor)
		addListOriginY = addListBtn.centerYAnchor.constraint(equalTo: centerBtn.centerYAnchor)
		addListDestX = addListBtn.rightAnchor.constraint(equalTo: rightBtn.rightAnchor)
		addListDestY = addListBtn.centerYAnchor.constraint(equalTo: addMemoBtn.bottomAnchor)
		addListOriginX.isActive = true
		addListOriginY.isActive = true
		addListDestX.isActive = false
		addListDestY.isActive = false
		addListBtn.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
		addListBtn.isHidden = true
	}
	
	// MARK: - Misc functions
	// Button factory
	private func scaledButton(icon: UIImage, tint: UIColor) -> UIButton {
		let btn = UIHelper.button(icon: icon, tint: tint)
		btn.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
		
		btn.layer.cornerRadius = lrgBtnSize / 2.0
		btn.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).cgColor
		btn.layer.shadowOpacity = 0.2
		btn.layer.shadowRadius = 2.0
		btn.layer.shadowOffset = CGSize.zero
		
		return btn
	}
	
}
