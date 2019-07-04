//
//  extensions.swift
//  MemoIt
//
//  Created by mk mk on 6/6/19.
//  Copyright © 2019 MC2. All rights reserved.
//

import UIKit
import AVFoundation


extension Notification.Name {
	// Norify home table reload edited item
	static let updateHomeTable = Notification.Name("UpdateHomeTable")
	// Notify home table new item has been added (reload table)
	static let newItemHomeTable = Notification.Name("NewItemHomeTable")
    // Notify dismiss MKPreseentationBottom controller
    static let dismissMKPresentationBottomVC = Notification.Name("dismissMKPresentationBottomVC")
    
    
}
