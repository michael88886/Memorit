//
//  MKButton.swift
//  ScheMo
//
//  Created by MICA17 on 11/3/19.
//  Copyright © 2019 MC2. All rights reserved.
//

import UIKit

class MKButton: UIButton {

    // MARK: - Properties
    // User background color
    var bgColor_user: UIColor = UIColor.clear
    // User tint color
    var tintColor_user: UIColor = #colorLiteral(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)
    // Highlighted background color
    var bgColor_highlight: UIColor = UIColor.clear
    // Highlighted tint color
    var tintColor_highlight: UIColor = UIColor.white
    
    
    // MARK: - Convenience init
    convenience init(image: UIImage) {
        self.init(type: .system)
        self.setImage(image, for: .normal)
        self.tintColor = tintColor_user
        self.tintAdjustmentMode = .normal
    }
    
    // MARK: - Override functions
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? bgColor_highlight : bgColor_user
            tintColor = isHighlighted ? tintColor_highlight : tintColor_user
        }
    }
    
    // MARK: - Public function
    func updateTintColor(color: UIColor) {
        self.tintColor = color
        self.tintColor_user = color
    }
}
