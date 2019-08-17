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
	// Notify home table new item has been added (reload table)
	static let newItemHomeTable = Notification.Name("NewItemHomeTable")
    // Notify dismiss MKPreseentationBottom controller
    static let dismissMKPresentationBottomVC = Notification.Name("dismissMKPresentationBottomVC")
    
    
}
