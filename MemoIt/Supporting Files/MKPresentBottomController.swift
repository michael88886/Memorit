//
//  MKPresentBottomController.swift
//  ScheMo
//
//  Created by Mica Palm P/L on 13/12/18.
//  Copyright © 2018 MC2. All rights reserved.
//

import UIKit

// MARK: - MKPresentBottomController protocol
public protocol MKPresentBottomProtocol {
    var controllerHeight: CGFloat { get }
}

// MARK: - MKPresentBottomController
class MKPresentBottomController: UIViewController, MKPresentBottomProtocol {

    // MARK: - Protocol variable
    var controllerHeight: CGFloat {
        return 0
    }
    
    // MARK: - OVerride functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add listener for dismiss controller
        NotificationCenter.default.addObserver(self, selector: #selector(dismissController), name: NSNotification.Name.dismissMKPresentationBottomVC, object: nil)
    }
    
    // Deinitialize
    deinit {	
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.dismissMKPresentationBottomVC, object: nil)
    }
}

// MARK: - Action
extension MKPresentBottomController {
    // Dismiss controller
    @objc func dismissController() {
        self.dismiss(animated: true, completion: nil)
    }
}
