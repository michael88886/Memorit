//
//  VoiceModel.swift
//  MemoIt
//
//  Created by mk mk on 10/6/19.
//  Copyright © 2019 MC2. All rights reserved.
//

import UIKit

class VoiceModel: MemoModel {
	// MARK: - Properties
	var memoID: String
	
	// MARK: Init
	override init() {
		self.memoID = String()
		super.init()
	}
}
