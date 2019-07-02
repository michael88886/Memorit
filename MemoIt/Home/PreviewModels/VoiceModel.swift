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
	var audioURL: URL!
	
	// MARK: Custom init
	init(memo: VoiceMemo) {
		super.init(memo: memo)
		self.type = MemoType.voice
	}
}
