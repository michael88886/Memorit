//
//  BadgeButton.swift
//  ScheMo
//
//  Created by Mica Palm P/L on 7/3/19.
//  Copyright © 2019 MC2. All rights reserved.
//

import UIKit

class BadgeButton: UIButton {
    
    // MARK: - Properties
    // Badge location offset
    private let badgeOffset: CGFloat = 8
    // Badge number reference
    private var badgeNumber: Int = 0
    
    // MARK:  - Views
    private lazy var badge: PaddingLabel = {
        let label = PaddingLabel()
        label.padding = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        label.backgroundColor = #colorLiteral(red: 1, green: 0.8039215686, blue: 0, alpha: 1)
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        label.text = "\(badgeNumber)"
        
        // Border
//        label.layer.borderWidth = 1
//        label.layer.borderColor = #colorLiteral(red: 0.370555222, green: 0.3705646992, blue: 0.3705595732, alpha: 1)
        return label
    }()
    
    // MARK: - Convenience init
    convenience init(withNumber: Int = 0) {
        self.init(type: .custom)
        self.badgeNumber = withNumber
        setup()
    }

    
    // MARK: - Public functions
    func updateCount(number: Int) {
        badgeNumber = number
        badge.text = "\(badgeNumber)"
        checkCount()
    }
}

// MARK: - BadgeBarButtonItem private functions
extension BadgeButton {
    private func setup() {
        // Badge
        badge.translatesAutoresizingMaskIntoConstraints = false
        addSubview(badge)
        badge.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.3).isActive = true
        badge.widthAnchor.constraint(greaterThanOrEqualTo: badge.heightAnchor).isActive = true
        badge.rightAnchor.constraint(equalTo: rightAnchor, constant: -badgeOffset).isActive = true
        badge.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -badgeOffset).isActive = true
    }
    
    // If badge is 0, hide badge
    private func checkCount() {
        badge.isHidden = (badgeNumber == 0 ? true : false)
        isEnabled = !badge.isHidden
        isEnabled ? (alpha = 1.0) : (alpha = 0.5)
    }
}
