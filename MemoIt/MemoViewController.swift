//
//  MemoViewController.swift
//  MemoIt
//
//  Created by mk mk on 6/6/19.
//  Copyright © 2019 MC2. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData

// Memo attachment type
enum AttachmentType: String {
	case image
	case audio
	
	var id: String {
		return self.rawValue
	}
}

struct MemoAttachment {
	var id: String
	var url: URL
	var type: AttachmentType
}

struct AttachmentModel {
	// Cover image
	var image: UIImage!
	// Duration string
	var duration: String?
}

private enum TableRow: Int {
	case timeRow = 0
	case titleRow = 1
	case contentRow = 2
}

class MemoViewController: UIViewController {

	// MARK: - Properties
	// - Constants
	// Default bar button color
	private let btnTintColor: UIColor = #colorLiteral(red: 0.370555222, green: 0.3705646992, blue: 0.3705595732, alpha: 1)
	// Date label font
	private let dateFont: UIFont = UIFont.systemFont(ofSize:12, weight: .regular)
	// Attachment collection width
	private let acWidth: CGFloat = UIScreen.main.bounds.width * 0.4
	// Attachment collection bottom constraint (keyboard show / hide)
	private var acBottomCst = NSLayoutConstraint()
	// Attachment collection right constraint (attachment collection show / hide)
	private var acRightCst = NSLayoutConstraint()
	// Attachment function container height
	private var acFuncH: CGFloat = 44
	// Attachment function container top constraint
	private var acTopCst = NSLayoutConstraint()



	
	
	// MARK: - Views
	
	
	
	// MARK: - 

  
}
// MARK: - Private functions
extension MemoViewController {} 

// MARK: - Actions
extension MemoViewController {} 

// MARK: - Override functions
extension MemoViewController {
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Do any additional setup after loading the view.
	}
	
	override func loadView() {
		super.loadView()
		
	}
} 

// MARK: - Delegates
// MARK: - 
// MARK: - 
