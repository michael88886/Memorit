//
//  AttachmentModel.swift
//  MemoIt
//
//  Created by MICA17 on 19/8/19.
//  Copyright © 2019 MC2. All rights reserved.
//

import UIKit

// Memo attachment type
enum AttachmentType: String {
    case image
    case audio
    
    var id: String {
        return self.rawValue
    }
}

// Attachment model
class AttachmentModel {
    // MARK: - Properties
    // - Variables
    // File name
    private(set) var filename: String
    // Directory
    private(set) var directory: URL
    // Attachment type
    private(set) var type: AttachmentType
    // Cover image
    private(set) var coverImage = UIImage()
    // Duration
    private(set) var duration = "00:00"
    
    // MARK: - Custom init
    init(fileName: String, directory: URL, type: AttachmentType) {
        self.filename = fileName
        self.directory = directory
        self.type = type
    }
    
    // Update duration
    func updateDuration(duration: String) {
        self.duration = duration
    }
    
    // Update cover
    func updateCover(image: UIImage) {
        self.coverImage = image
    }   
}
