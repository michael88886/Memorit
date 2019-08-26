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
//	let prevImageSize = CGSize(width: 80, height: 80)
	
	// - Variables
	// Preview text
	var prevText: NSAttributedString?
	// Preview image
	var prevImage: UIImage?
	// Have attachment flag
	var haveAttachment: Bool = false
	
	// MARK: - Custom init
	init(memo: AttachmentMemo) {
		self.prevText = memo.attributedString
		super.init(memo: memo)
		self.type = MemoType.attach
	}
}

