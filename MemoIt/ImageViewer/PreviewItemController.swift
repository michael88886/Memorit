//
//  PreviewItemController.swift
//  ScheMo
//
//  Created by MICA17 on 4/4/19.
//  Copyright © 2019 MC2. All rights reserved.
//

import UIKit

class PreviewItemController: UIViewController {

    // MARK: - Properties
    var attachment: MemoAttachment!
    
    // MARK: - Views
    // - Image view
    lazy var imageView: UIImageView = {
        let imgV = UIImageView()
        imgV.contentMode = .scaleAspectFit
        return imgV
    }()
    
    init(attachment: MemoAttachment) {
        super.init(nibName: nil, bundle: nil)
        self.attachment = attachment
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError()
    }
    
    // Override functions
    override func loadView() {
        super.loadView()
        view.backgroundColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

}

