//
//  ListDetailViewController.swift
//  MemoIt
//
//  Created by mk mk on 6/6/19.
//  Copyright © 2019 MC2. All rights reserved.
//

import UIKit

class ListDetailViewController: MKPresentBottomController {

    // MARK: - Properties
    // - Constants
    private let btnW: CGFloat = 60
    // Text view height
	private let txViewH: CGFloat = 100
    
    // MARK: Views
	// Scroll view
	private lazy var scrollView = UIScrollView()
	
	// Title field
	private lazy var titleTextView: UITextView = {
		let tv = UITextView()
		tv.backgroundColor = .clear
		tv.tintColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
		tv.textColor = #colorLiteral(red: 0.370555222, green: 0.3705646992, blue: 0.3705595732, alpha: 1)
		tv.showsVerticalScrollIndicator = false
		tv.allowsEditingTextAttributes = true
		tv.adjustsFontForContentSizeCategory = true
		tv.autocorrectionType = .no
		tv.typingAttributes = [.font: UIFont.systemFont(ofSize: 18),
							   .foregroundColor: #colorLiteral(red: 0.6642242074, green: 0.6642400622, blue: 0.6642315388, alpha: 1)]
		tv.layer.borderColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1).cgColor
		tv.layer.borderWidth = 1.0
		return tv
	}()
	
    // Add button
    private lazy var addBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("Add item", for: .normal)
        btn.setTitleColor(UIHelper.defaultTint, for: .normal)
        btn.addTarget(self, action: #selector(addAction), for: .touchUpInside)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
		titleTextView.becomeFirstResponder()
    }

    // MARK: - View controller height
    override var controllerHeight: CGFloat {
        return UIScreen.main.bounds.height * 0.7
    }
}

// MARK: - PRivate function
extension ListDetailViewController {}

// MARK: - Actions
extension ListDetailViewController {
    // Cancel action
    @objc private func cancelAction() {
        print("Cancel action")
		titleTextView.resignFirstResponder()
		NotificationCenter.default.post(name: NSNotification.Name.dismissMKPresentationBottomVC, object: nil)
    }
    
    // Add action
    @objc private func addAction() {
        print("Add action")
    }
    
}

// MARK: - Setup UI
extension ListDetailViewController {
    override func loadView() {
        super.loadView()
        
        view.backgroundColor = .white
        view.layer.cornerRadius = 24
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
		// Title
		let titleLabel = UILabel()
		titleLabel.textAlignment = .left
		titleLabel.textColor = UIHelper.defaultTint
		titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .medium)
		titleLabel.text = "Task"
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(titleLabel)
		titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: Padding.p20).isActive = true
		titleLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: Padding.p30).isActive = true
		
        // Cancel button
        let cancelBtn = UIButton(type: .custom)
        cancelBtn.setImage(#imageLiteral(resourceName: "Cross44"), for: .normal)
        cancelBtn.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        cancelBtn.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cancelBtn)
        cancelBtn.heightAnchor.constraint(equalToConstant: UIHelper.defaultH).isActive = true
		cancelBtn.widthAnchor.constraint(equalToConstant: UIHelper.defaultH).isActive = true
        cancelBtn.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor).isActive = true
        cancelBtn.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -Padding.p20).isActive = true
		
		// Separator
		let sep = UIView()
		sep.isUserInteractionEnabled = false
		sep.backgroundColor = #colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1)
		sep.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(sep)
		sep.heightAnchor.constraint(equalToConstant: 1).isActive = true
		sep.leftAnchor.constraint(equalTo: view.leftAnchor, constant: Padding.p20).isActive = true
		sep.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -Padding.p20).isActive = true
		sep.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Padding.p5).isActive = true
        
		// Scroll view
		scrollView.keyboardDismissMode = .interactive
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(scrollView)
		scrollView.topAnchor.constraint(equalTo: sep.bottomAnchor).isActive = true
		scrollView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
		scrollView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
		scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
		
		// Content view
		let contentView = UIView()
		contentView.translatesAutoresizingMaskIntoConstraints = false
		scrollView.addSubview(contentView)
		contentView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
		contentView.leftAnchor.constraint(equalTo: scrollView.leftAnchor).isActive = true
		contentView.rightAnchor.constraint(equalTo: scrollView.rightAnchor).isActive = true
		contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
		contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
		contentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor).isActive = true
		
		// Title text view
		titleTextView.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(titleTextView)
		titleTextView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Padding.p10).isActive = true
		titleTextView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: Padding.p30).isActive = true
		titleTextView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -Padding.p30).isActive = true
		titleTextView.heightAnchor.constraint(equalToConstant: txViewH).isActive = true

		// Color title
		let colorTitle = UILabel()
		colorTitle.font = UIFont.systemFont(ofSize: 18)
		colorTitle.textAlignment = .left
		colorTitle.textColor = UIHelper.defaultTint
		colorTitle.text = "Color tag"
		colorTitle.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(colorTitle)
		colorTitle.topAnchor.constraint(equalTo: titleTextView.bottomAnchor, constant: Padding.p20).isActive = true
		colorTitle.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: Padding.p20).isActive = true
		
		// Color collection
		
		// Reminder title
		
		// Reminder picker
		
		// Add button
//        addBtn.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(addBtn)
//        addBtn.heightAnchor.constraint(equalToConstant: UIHelper.defaultH).isActive = true
//        addBtn.topAnchor.constraint(equalTo: view.topAnchor, constant: Padding.p10).isActive = true
//        addBtn.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -Padding.p20).isActive = true
        
    }
}
