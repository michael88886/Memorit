//
//  FunctionView.swift
//  MemoIt
//
//  Created by mk mk on 7/6/19.
//  Copyright © 2019 MC2. All rights reserved.
//

import UIKit

class FunctionView: UIView {

	// MARK: - Properties
	let btnTint: UIColor = #colorLiteral(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)
	
	
	// MARK: - Views
	// Add button
	private lazy var addBtn: UIButton = {
		let btn = UIHelper.button(icon: , tint: <#T##UIColor#>)
		
		return btn
	}()
	
	// Setting button
	private lazy var settingBtn: UIButton = {
		let btn = UIButton()
		
		
		return btn
	}()
	
	// Edit button
	private lazy var editBtn: UIButton = {
		let btn = UIButton()
		
		return btn
	}()
	
	
	// MARK: - Custom init
	override init(frame: CGRect) {
		super.init(frame: frame)
		loadView()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		loadView()
	}

}


// MAKR: - Private functions
extension FunctionView {
	// Setup view
	private func loadView() {
		
		
		
	}
	
}
