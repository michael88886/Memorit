//
//  extensions.swift
//  MemoIt
//
//  Created by mk mk on 6/6/19.
//  Copyright © 2019 MC2. All rights reserved.
//

import UIKit
import AVFoundation

// Notification.Name
extension Notification.Name {
	// Norify reload home list
	static let reloadHomeList = Notification.Name("ReloadHomeList")
	// Notify add new memo to ilst
	static let addNewMemo = Notification.Name("AddNewMemo")
    // Notify dismiss MKPreseentationBottom controller
    static let dismissMKPresentationBottomVC = Notification.Name("dismissMKPresentationBottomVC")
    
    
}
