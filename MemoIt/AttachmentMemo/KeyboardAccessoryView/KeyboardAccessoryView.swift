//
//  KeyboardAccessoryView.swift
//  MemoIt
//
//  Created by mk mk on 18/8/19.
//  Copyright © 2019 MC2. All rights reserved.
//

import UIKit

// MARK: - KeyboardAccessoryView delegate
protocol KeyboardAccessoryViewDelegate: class {
	// Drawing action
	func drawing()
	// Recorder action
	func recorder()
	// Photo album action
	func album()
	// Camera action
	func camera()
	
	// Bold text action
	func boldText(activate: Bool)
	// Italic text action
	func italicText(activate: Bool)
	// Underline text action
	func underlineText(activate:Bool)
	// Strike through text action
	func strikeThoughText(activate:Bool)
}


final class KeyboardAccessoryView: UIView {
	// MARK: - Properties
	// - Enums
	// Keyboard mode
	private enum KeyboardMode {
		case attachment
		case textStyle
	}
	
	// Keyboard funciton
	private enum KeyboardFunction {
		// Attachment functions
		case drawing
		case voice
		case album
		case camera
//		case map
		
		// Text functions
		case bold
		case italic
		case underline
		case strikeThrough
	}
	
	
	// - Constants
	// Sub-collection cell ID
	private let subCellID = "SubCell"
	
	// Button width
	private let btnW: CGFloat = 48
	
	// Button height
	private let btnH: CGFloat = 32
	
	// Button tint color
	private let btnTint: UIColor = #colorLiteral(red: 0.5704585314, green: 0.5704723597, blue: 0.5704649091, alpha: 1)
	
	// Button corner radius
	private let btnCR: CGFloat = 4
	
	// Highlighted tint color
	private let highlightTintColor: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
	
	// Selected background color
	private let selectedBGColor: UIColor = #colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1)
	
	// Feedback generator
	private let tapFeedback = UIImpactFeedbackGenerator(style: .medium)
	
	
	// - Variables
	// Keyboard mode
	private var keyboardMode: KeyboardMode = .textStyle
	
	// Select view axis attach constraint
	private var attAxisCst: NSLayoutConstraint = NSLayoutConstraint()
	
	// Select view axis text constraint
	private var textAxisCst: NSLayoutConstraint = NSLayoutConstraint()
	
	// Font bold flag
	private var isBold: Bool = false
	
	// Font italic flag
	private var isItalic: Bool = false
	
	// Font underline flag
	private var isUnderline: Bool = false
	
	// Font highlight flag
	private var isStrikeThrough: Bool = false
	
	// Attachment functions
	private let attFuncs: [(image: UIImage, funcName: KeyboardFunction)] = [(#imageLiteral(resourceName: "Drawing"), .drawing),
																			(#imageLiteral(resourceName: "Mic"), .voice),
																			(#imageLiteral(resourceName: "CamLibrary"), .album),
																			(#imageLiteral(resourceName: "Camera"), .camera)]
	// Text functions
	private let textFuncs: [(image: UIImage, funcName: KeyboardFunction)] = [(#imageLiteral(resourceName: "Bold"), .bold),
																			 (#imageLiteral(resourceName: "Italic"), .italic),
																			 (#imageLiteral(resourceName: "Underline"), .underline),
																			 (#imageLiteral(resourceName: "StrikeThrough"), .strikeThrough)]

	// Delegate
	weak var delegate: KeyboardAccessoryViewDelegate?
	
	
	// MARK: - Views
	// Attachment button
	private lazy var attchBtn = keyboardButton(image: #imageLiteral(resourceName: "Pin44"))
	
	// Text button
	private lazy var textBtn = keyboardButton(image: #imageLiteral(resourceName: "Text"))
	
	// Select view
	private lazy var selectView: UIView = {
		let sv = UIView()
		sv.backgroundColor = #colorLiteral(red: 1, green: 0.8039215686, blue: 0, alpha: 1)
		sv.isUserInteractionEnabled = false
		sv.layer.cornerRadius = 8
		return sv
	}()
	
	// Sub-function collection view
	private lazy var subCollection: UICollectionView = {
		// Layout
		let layout = UICollectionViewFlowLayout()
		layout.scrollDirection = .horizontal
		layout.minimumInteritemSpacing = 2
		layout.minimumLineSpacing = 15
		
		// Collection view
		let collection = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
		collection.backgroundColor = UIColor.clear
		collection.showsVerticalScrollIndicator = false
		collection.showsHorizontalScrollIndicator = false
		return collection
	}()
	
	
	// MARK: - Override init
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupUI()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		fatalError()
	}
}

// MARK: - Public funtion
extension KeyboardAccessoryView {
	func updateState(attribute: [NSAttributedString.Key: Any]) {
		// Bold, italic
		let font: UIFont = attribute[.font] as! UIFont
		let trait = font.fontDescriptor.symbolicTraits
		isBold = trait.contains(UIFontDescriptor.SymbolicTraits.traitBold)
		isItalic = trait.contains(UIFontDescriptor.SymbolicTraits.traitItalic)
		
		// Underline
		isUnderline = false
		if let underStyle = attribute[.underlineStyle] as? NSNumber {
			if underStyle.intValue > 0 {
				isUnderline = true
			}
		}
		
		// Strike through
		isStrikeThrough = false
		if let strikeThrough = attribute[.strikethroughStyle] as? NSNumber {
			if strikeThrough.intValue > 0 {
				isStrikeThrough = true
			}
		}
		
		if keyboardMode == .textStyle {
			subCollection.reloadData()
		}
	}
}

// MARK: - Private function
extension KeyboardAccessoryView {
	// Keyboard button
	private func keyboardButton(image: UIImage) -> UIButton {
		let btn = UIButton(type: .system)
		btn.imageView?.contentMode = .scaleAspectFit
		btn.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
		btn.tintColor = btnTint
//		btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
		btn.layer.cornerRadius = btnCR
		return btn
	}
	
	// Keyboard input mode
	private func keyboardInputMode() {
		// Reload functions
		subCollection.reloadData()
		
		// Update select view position
		switch keyboardMode {
		case .attachment:
			textAxisCst.isActive = false
			attAxisCst.isActive = true
			
			UIView.animate(withDuration: 0.2) {
				self.attchBtn.tintColor = self.highlightTintColor
				self.textBtn.tintColor = self.btnTint
				self.layoutIfNeeded()
			}
			
		case .textStyle:
			attAxisCst.isActive = false
			textAxisCst.isActive = true
			
			UIView.animate(withDuration: 0.2) {
				self.attchBtn.tintColor = self.btnTint
				self.textBtn.tintColor = self.highlightTintColor
				self.layoutIfNeeded()
			}
		}
	}
	
	// Keyboard actions
	private func keyboardAction(funcName: KeyboardFunction) {
		switch funcName {
		case .drawing:
			self.delegate?.drawing()
		case .voice:
			self.delegate?.recorder()
		case .album:
			self.delegate?.album()
		case .camera:
			self.delegate?.camera()
		case .bold:
			self.delegate?.boldText(activate: isBold)
		case .italic:
			self.delegate?.italicText(activate: isItalic)
		case .underline:
			self.delegate?.underlineText(activate: isUnderline)
		case .strikeThrough:
			self.delegate?.strikeThoughText(activate: isStrikeThrough)
		}
	}
}

// MARK: - Actions
extension KeyboardAccessoryView {
	// Attachment action
	@objc private func attachAction() {
		tapFeedback.impactOccurred()
		
		// Optimize performce, prevent function activate repeatly
		attchBtn.isUserInteractionEnabled = false
		textBtn.isUserInteractionEnabled = true
		
		// Set keyboard mode, update sub collection functions
		keyboardMode = .attachment
		keyboardInputMode()
	}
	
	// Text action
	@objc private func textAction() {
		tapFeedback.impactOccurred()
		
		// Optimize performce, prevent function activate repeatly
		textBtn.isUserInteractionEnabled = false
		attchBtn.isUserInteractionEnabled = true
		
		// Set keyboard mode, update sub collection functions
		keyboardMode = .textStyle
		keyboardInputMode()
	}
}

// MARK: - Delegate
// MARK: - CollectionView data source / delegate
extension KeyboardAccessoryView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	// Number of cell
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		switch keyboardMode {
		case .attachment:
			return attFuncs.count
		case .textStyle:
			return textFuncs.count
		}
	}
	
	// Setup cell
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: subCellID, for: indexPath) as! KeyboardAccessoryCell
		cell.imageView.tintColor = btnTint
		cell.selectColor = #colorLiteral(red: 1, green: 0.8039215686, blue: 0, alpha: 1)
		
		switch keyboardMode {
		case .attachment:
			cell.imageView.image = attFuncs[indexPath.row].image.withRenderingMode(.alwaysTemplate)
			
		case .textStyle:
			cell.imageView.image = textFuncs[indexPath.row].image.withRenderingMode(.alwaysTemplate)
			
			let funcID = textFuncs[indexPath.row].funcName
			switch funcID {
			case .bold:
				if isBold { cell.selectCell() }
			case .italic:
				if isItalic { cell.selectCell() }
			case .underline:
				if isUnderline { cell.selectCell() }
			case .strikeThrough:
				if isStrikeThrough { cell.selectCell() }
			default:
				()
			}
		}
		
		return cell
	}
	
	// Select cell
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		tapFeedback.impactOccurred()
		
		switch keyboardMode {
		case .attachment:
			let funcID = attFuncs[indexPath.row].funcName
			keyboardAction(funcName: funcID)
		case .textStyle:
			let funcID = textFuncs[indexPath.row].funcName
			switch funcID {
			case .bold:
				isBold = !isBold
			case .italic:
				isItalic = !isItalic
			case .underline:
				isUnderline = !isUnderline
			case .strikeThrough:
				isStrikeThrough = !isStrikeThrough
			default:
				()
			}
			keyboardAction(funcName: funcID)
			collectionView.reloadItems(at: [indexPath])
		}
	}
	
	// Cell size
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		// Flow layout
		let layout = collectionViewLayout as! UICollectionViewFlowLayout
		// Padding
		let padding = layout.minimumInteritemSpacing * 2
		let height = collectionView.frame.height - padding
		return CGSize(width: btnW, height: height)
	}
}

// MARK: - Setup UI
extension KeyboardAccessoryView {
	private func setupUI() {
		// Background color
		backgroundColor = #colorLiteral(red: 0.9725490196, green: 0.9725490196, blue: 0.9725490196, alpha: 1)
		
		// Text button
		textBtn.addTarget(self, action: #selector(textAction), for: .touchUpInside)
		addSubview(textBtn)
		textBtn.translatesAutoresizingMaskIntoConstraints = false
		textBtn.widthAnchor.constraint(equalToConstant: btnW).isActive = true
		textBtn.heightAnchor.constraint(equalToConstant: btnH).isActive = true
		textBtn.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Padding.p10).isActive = true
		textBtn.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
		
		// Attachment button
		attchBtn.addTarget(self, action: #selector(attachAction), for: .touchUpInside)
		addSubview(attchBtn)
		attchBtn.translatesAutoresizingMaskIntoConstraints = false
		attchBtn.widthAnchor.constraint(equalToConstant: btnW).isActive = true
		attchBtn.heightAnchor.constraint(equalToConstant: btnH).isActive = true
		attchBtn.leadingAnchor.constraint(equalTo: textBtn.trailingAnchor, constant: Padding.p5).isActive = true
		attchBtn.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
		
		// Select view
		insertSubview(selectView, at: 0)
		selectView.translatesAutoresizingMaskIntoConstraints = false
		selectView.widthAnchor.constraint(equalToConstant: btnW).isActive = true
		selectView.heightAnchor.constraint(equalToConstant: btnH).isActive = true
		selectView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
		attAxisCst = selectView.centerXAnchor.constraint(equalTo: attchBtn.centerXAnchor)
		textAxisCst = selectView.centerXAnchor.constraint(equalTo: textBtn.centerXAnchor)
		attAxisCst.isActive = true
		textAxisCst.isActive = false
		
		// Separator
		let sep = UIHelper.separator(withColor: #colorLiteral(red: 0.7540688515, green: 0.7540867925, blue: 0.7540771365, alpha: 1))
		addSubview(sep)
		sep.translatesAutoresizingMaskIntoConstraints = false
		sep.widthAnchor.constraint(equalToConstant: 1).isActive = true
		sep.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.5).isActive = true
		sep.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
		sep.leadingAnchor.constraint(equalTo: textBtn.trailingAnchor, constant: Padding.p10).isActive = true
		
		// Sub collection view
		subCollection.dataSource = self
		subCollection.delegate = self
		subCollection.register(KeyboardAccessoryCell.self, forCellWithReuseIdentifier: subCellID)
		addSubview(subCollection)
		subCollection.translatesAutoresizingMaskIntoConstraints = false
		subCollection.topAnchor.constraint(equalTo: topAnchor).isActive = true
		subCollection.leadingAnchor.constraint(equalTo: sep.trailingAnchor, constant: Padding.p10).isActive = true
		subCollection.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Padding.p5).isActive = true
		subCollection.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
		
		// Default keyboard input mode
		keyboardInputMode()
	}
}
