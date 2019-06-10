//
//  AttachModel.swift
//  MemoIt
//
//  Created by mk mk on 10/6/19.
//  Copyright © 2019 MC2. All rights reserved.
//

import UIKit

class AttachModel: MemoModel {
	//MARK: - Properties
	// - Constants
	// Preview image size
	let prevImageSize = CGSize(width: 80, height: 80)
	
	// - Variables
	// Memo ID
	var memoID: String
	// Preview text
	var prevText: NSAttributedString
	// Preview image
	var prevImage: UIImage?
	// Have attachment flag
	var haveAttachment: Bool = false
	
	// MARK: - Init
	override init() {
		self.prevText = NSAttributedString()
		self.memoID = String()
		self.prevImage = nil
		super.init()
	}
}

