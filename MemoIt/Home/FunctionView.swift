//
//  FunctionView.swift
//  MemoIt
//
//  Created by mk mk on 7/6/19.
//  Copyright © 2019 MC2. All rights reserved.
//

import UIKit

// MARK:- FuntionView delegate
protocol FunctionViewDelegate: class {
	// Function actions
	func menuAction()
	func moreAction()
	
	func showOption()
	func hideOption(animated: Bool)
	
	// Editing actions
	func addMemo()
	func addVoice()
	func addTodoList()
}


class FunctionView: UIView {
	// MARK: - Properties
	// - Constant
	// Button tint size
	private let btnTint: UIColor = #colorLiteral(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)
	// Center button width
	private let ctrBtnW: CGFloat = 144
	// Center button height
	private let ctrBtnH: CGFloat = 44
	// Button size
	private let btnSize: CGFloat = 40
	// Large button size
	private let lrgBtnSize: CGFloat = 60
	// Original height
	let originalH: CGFloat = 60
	// Expand height
	let expandH: CGFloat = 144
	
	// - Add center button width constraint
	// Original Y
	private var ctrBtnYOriCst = NSLayoutConstraint()
	// Expanded Y
	private var ctrBtnYExpCst = NSLayoutConstraint()
	
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
	
	// - Variables
	// Expand flag
	private(set) var isExpanded = false
	// Delegate
	weak var delegate: FunctionViewDelegate?
	
	// MARK: - Views
	// Add button
	private lazy var addBtn: UIButton = {
		let btn = UIHelper.button(icon: #imageLiteral(resourceName: "Plus44"), tint: btnTint)
		btn.addTarget(self, action: #selector(centerAction), for: .touchUpInside)
		btn.backgroundColor = #colorLiteral(red: 1, green: 0.8039215686, blue: 0, alpha: 1)
		btn.tintColor = .white
		btn.imageEdgeInsets.left = -15
		btn.titleEdgeInsets.right = 10
		btn.setTitle("Add memo", for: .normal)
		btn.titleLabel?.font = UIFont.monospacedDigitSystemFont(ofSize: 14, weight: .medium)
		btn.layer.cornerRadius = ctrBtnH / 2.0
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
		let btn = UIHelper.button(icon: #imageLiteral(resourceName: "Dots44"), tint: btnTint)
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
		// Center button
		ctrBtnYOriCst.isActive = false
		ctrBtnYExpCst.isActive = true
		
		// Add memo button
		memoBtn.alpha = 0
		memoBtn.isHidden = false
		
		// Add voice button
		voiceBtn.alpha = 0
		voiceBtn.isHidden = false
		addVoiceOriginX.isActive = false
		addVoiceOriginY.isActive = false
		addVoiceDestX.isActive = true
		addVoiceDestY.isActive = true
		
		// Add list button
		todoBtn.alpha = 0
		todoBtn.isHidden = false
		addListOriginX.isActive = false
		addListOriginY.isActive = false
		addListDestX.isActive = true
		addListDestY.isActive = true
	}
	
	func hideOption() {
		// Center button
		ctrBtnYExpCst.isActive = false
		ctrBtnYOriCst.isActive = true
		
		// Add memo button
		memoBtn.alpha = 1
		
		// Add voice button
		voiceBtn.alpha = 1
		addVoiceDestX.isActive = false
		addVoiceDestY.isActive = false
		addVoiceOriginX.isActive = true
		addVoiceOriginY.isActive = true
		
		// Add list button
		todoBtn.alpha = 1
		addListDestX.isActive = false
		addListDestY.isActive = false
		addListOriginX.isActive = true
		addListOriginY.isActive = true
	}
	
	func showOptionTransition() {
		// Center button
		addBtn.backgroundColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
		addBtn.setTitle("Cancel", for: .normal)
		addBtn.setImage(#imageLiteral(resourceName: "Cross44").withRenderingMode(.alwaysTemplate), for: .normal)
		addBtn.tintColor = .white
		
		// Add memo button
		memoBtn.transform = CGAffineTransform(scaleX: 1, y: 1)
		memoBtn.alpha = 1
		
		// Add voice button
		voiceBtn.transform = CGAffineTransform(scaleX: 1, y: 1)
		voiceBtn.alpha = 1
		
		// Add list buttion
		todoBtn.transform = CGAffineTransform(scaleX: 1, y: 1)
		todoBtn.alpha = 1
		
		// Self
		layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
	}
	
	func hideOptionTransition() {
		// Center button
		addBtn.backgroundColor = #colorLiteral(red: 1, green: 0.8039215686, blue: 0, alpha: 1)
		addBtn.setTitle("Add memo", for: .normal)
		addBtn.setImage(#imageLiteral(resourceName: "Plus44").withRenderingMode(.alwaysTemplate), for: .normal)
		addBtn.tintColor = .white
		
		// Add memo button
		memoBtn.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
		memoBtn.alpha = 0
		
		// Add voice button
		voiceBtn.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
		voiceBtn.alpha = 0
		
		// Add list buttion
		todoBtn.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
		todoBtn.alpha = 0
		
		// Self
		layer.maskedCorners = []
	}
	
	func showCompleted() {
		// Disable left / right buttons
		menuBtn.isEnabled = false
		moreBtn.isEnabled = false		
	}
	
	func hideCompleted(){
		
		
		// Enable left / right buttons
		menuBtn.isEnabled = true
		moreBtn.isEnabled = true
		
		// Hide function buttons
		memoBtn.isHidden = true
		voiceBtn.isHidden = true
		todoBtn.isHidden = true
	}
}

// MARK: - Actions
extension FunctionView {
	// Center action
	@objc private func centerAction() {
		if isExpanded {
			// Hide optiom
			delegate?.hideOption(animated: true)
		}
		else {
			// Show option
			delegate?.showOption()
		}
		isExpanded = !isExpanded
	}
	
	// Menu action
	@objc private func menuAction() {
		delegate?.menuAction()
	}
	
	// More action
	@objc private func moreAction() {
		delegate?.moreAction()
	}
	
	// Add voice action
	@objc private func addVoiceAction() {
		delegate?.addVoice()
	}
	
	// Add todo action
	@objc private func addTodoAction() {
		delegate?.addTodoList()
	}
	
	// Add memo action
	@objc private func addMemoAction() {
		delegate?.addMemo()
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
		addBtn.translatesAutoresizingMaskIntoConstraints = false
		addSubview(addBtn)
		addBtn.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
		ctrBtnYExpCst = addBtn.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Padding.p20)
		ctrBtnYOriCst = addBtn.centerYAnchor.constraint(equalTo: topAnchor, constant: Padding.p10)
		ctrBtnYOriCst.isActive = true
		addBtn.widthAnchor.constraint(equalToConstant: ctrBtnW).isActive = true
		addBtn.heightAnchor.constraint(equalToConstant: ctrBtnH).isActive = true
		
		// Menu button
		menuBtn.translatesAutoresizingMaskIntoConstraints = false
		addSubview(menuBtn)
		menuBtn.widthAnchor.constraint(equalToConstant: btnSize).isActive = true
		menuBtn.heightAnchor.constraint(equalToConstant: btnSize).isActive = true
		menuBtn.leftAnchor.constraint(equalTo: leftAnchor, constant: Padding.p20).isActive = true
		menuBtn.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
		
		// More button
		moreBtn.translatesAutoresizingMaskIntoConstraints = false
		addSubview(moreBtn)
		moreBtn.widthAnchor.constraint(equalToConstant: btnSize).isActive = true
		moreBtn.heightAnchor.constraint(equalToConstant: btnSize).isActive = true
		moreBtn.rightAnchor.constraint(equalTo: rightAnchor, constant: -Padding.p20).isActive = true
		moreBtn.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
		
		
		// Add memo button
		memoBtn.translatesAutoresizingMaskIntoConstraints = false
		insertSubview(memoBtn, belowSubview: addBtn)
		memoBtn.widthAnchor.constraint(equalToConstant: lrgBtnSize).isActive = true
		memoBtn.heightAnchor.constraint(equalToConstant: lrgBtnSize).isActive = true
		memoBtn.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
		memoBtn.topAnchor.constraint(equalTo: topAnchor, constant: Padding.p20).isActive = true
		memoBtn.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
		memoBtn.isHidden = true
		
		// Add voice button
		voiceBtn.translatesAutoresizingMaskIntoConstraints = false
		//        addVoiceBtn.backgroundColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
		insertSubview(voiceBtn, belowSubview: addBtn)
		voiceBtn.widthAnchor.constraint(equalToConstant: lrgBtnSize).isActive = true
		voiceBtn.heightAnchor.constraint(equalToConstant: lrgBtnSize).isActive = true
		addVoiceOriginX = voiceBtn.centerXAnchor.constraint(equalTo: addBtn.centerXAnchor)
		addVoiceOriginY = voiceBtn.centerYAnchor.constraint(equalTo: addBtn.centerYAnchor)
		addVoiceDestX = voiceBtn.leftAnchor.constraint(equalTo: menuBtn.leftAnchor)
		addVoiceDestY = voiceBtn.centerYAnchor.constraint(equalTo: memoBtn.bottomAnchor)
		addVoiceOriginX.isActive = true
		addVoiceOriginY.isActive = true
		addVoiceDestX.isActive = false
		addVoiceDestY.isActive = false
		voiceBtn.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
		voiceBtn.isHidden = true
		
		// Add check list button
		todoBtn.translatesAutoresizingMaskIntoConstraints = false
		//        addListBtn.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
		insertSubview(todoBtn, belowSubview: addBtn)
		todoBtn.widthAnchor.constraint(equalToConstant: lrgBtnSize).isActive = true
		todoBtn.heightAnchor.constraint(equalToConstant: lrgBtnSize).isActive = true
		addListOriginX = todoBtn.centerXAnchor.constraint(equalTo: addBtn.centerXAnchor)
		addListOriginY = todoBtn.centerYAnchor.constraint(equalTo: addBtn.centerYAnchor)
		addListDestX = todoBtn.rightAnchor.constraint(equalTo: moreBtn.rightAnchor)
		addListDestY = todoBtn.centerYAnchor.constraint(equalTo: memoBtn.bottomAnchor)
		addListOriginX.isActive = true
		addListOriginY.isActive = true
		addListDestX.isActive = false
		addListDestY.isActive = false
		todoBtn.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
		todoBtn.isHidden = true
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
