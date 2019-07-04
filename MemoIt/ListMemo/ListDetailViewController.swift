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
    
    
    // MARK: Views
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
    }

    // MARK: - View controller height
    override var controllerHeight: CGFloat {
        return UIScreen.main.bounds.height * 0.8
    }
}

// MARK: - PRivate function
extension ListDetailViewController {}

// MARK: - Actions
extension ListDetailViewController {
    // Cancel action
    @objc private func cancelAction() {
        print("Cancel action")
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
        view.layer.cornerRadius = 40
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        // Cancel button
        let cancelBtn = UIButton(type: .custom)
        cancelBtn.setTitle("Cancel", for: .normal)
        cancelBtn.setTitleColor(.red, for: .normal)
        cancelBtn.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        cancelBtn.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cancelBtn)
        cancelBtn.heightAnchor.constraint(equalToConstant: UIHelper.defaultH).isActive = true
        cancelBtn.topAnchor.constraint(equalTo: view.topAnchor, constant: Padding.p10).isActive = true
        cancelBtn.leftAnchor.constraint(equalTo: view.leftAnchor, constant: Padding.p20).isActive = true
        
        // Add button
        addBtn.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(addBtn)
        addBtn.heightAnchor.constraint(equalToConstant: UIHelper.defaultH).isActive = true
        addBtn.topAnchor.constraint(equalTo: view.topAnchor, constant: Padding.p10).isActive = true
        addBtn.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -Padding.p20).isActive = true
        
        // Separator
        let sep = UIView()
        sep.isUserInteractionEnabled = false
        sep.backgroundColor = #colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1)
        sep.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sep)
        sep.heightAnchor.constraint(equalToConstant: 1).isActive = true
        sep.leftAnchor.constraint(equalTo: view.leftAnchor, constant: Padding.p20).isActive = true
        sep.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -Padding.p20).isActive = true
        sep.topAnchor.constraint(equalTo: cancelBtn.bottomAnchor).isActive = true
        
        // Title text view
        
        // Color title
        
        // Color collection
        
        // Reminder title
        
        // Reminder picker
        
    }
}
