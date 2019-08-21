//
//  LoadAttachmentOperation.swift
//  MemoIt
//
//  Created by MICA17 on 19/8/19.
//  Copyright © 2019 MC2. All rights reserved.
//

import UIKit

class LoadAttachmentOperation: Operation {
    // MARK: - Properties
    // - Constants
    // Cover image size
    private let coverSize = CGSize(width: 80, height: 80)
    
    // - Variables
    // Attachment model
    var attachmentModel: AttachmentModel?
    // Loaded flag
    private(set) var loaded = false
    
    // - Closure
    // Completion handler
    var completionHandler: ((AttachmentModel) -> Void)?
    
    
    // MARK: - Initialiser
    init(attachment: AttachmentModel) {
        self.attachmentModel = attachment
    }
    
    // MARK: - Override main
    override func main() {
        // Check if cancel before start
        if isCancelled { return }
        
        // Processing
        guard let model = self.attachmentModel else { return }
        
        var image: UIImage?
        
        switch model.type {
        case .image:
            image = UIImage(contentsOfFile: model.directory.path)
            
        case .audio:
			image = #imageLiteral(resourceName: "SoundWave44")
            let duraStr = Helper.mediaDuration(url: model.directory)
            model.updateDuration(duration: duraStr)
        }
        
        if let coverImage = Helper.imageThumbnail(image: image ?? #imageLiteral(resourceName: "Attach44"),
                                                  targetSize: coverSize,
                                                  quality: 0.25) {
            model.updateCover(image: coverImage)
            self.loaded = true
        }
        
        // Completion
        if let complete = completionHandler {
            DispatchQueue.main.async {
                complete(model)
            }
        }
    }
}
