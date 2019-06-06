//
//  ImageViewerController.swift
//  ScheMo
//
//  Created by MICA17 on 17/11/18.
//  Copyright © 2018 MC2. All rights reserved.
//

import UIKit

final class PreviewImageController: PreviewItemController {

    // MARK: - Properties
    // Minimum scale
    private let minimumScale: CGFloat = 1.0
    // Maximum scale
    private let maximumScale: CGFloat = 3.0
    
    // MARK: - Views
    // Scroll view
    private lazy var scrollView: UIScrollView = {
        let sV = UIScrollView()
        sV.showsVerticalScrollIndicator = false
        sV.showsHorizontalScrollIndicator = false
        sV.minimumZoomScale = minimumScale
        sV.maximumZoomScale = maximumScale
        sV.delegate = self
        return sV
    }()
    
    // MARK: - Override functions
    override func loadView() {
        super.loadView()
        
        // Scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        scrollView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        // Image view
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(imageView)
        imageView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        imageView.leftAnchor.constraint(equalTo: scrollView.leftAnchor).isActive = true
        imageView.rightAnchor.constraint(equalTo: scrollView.rightAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        imageView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo: scrollView.heightAnchor).isActive = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Gestures
        // - Single tap
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(singleTapHandler(_:)))
        singleTap.numberOfTapsRequired = 1
        singleTap.numberOfTouchesRequired = 1
        imageView.addGestureRecognizer(singleTap)
        
        // - Double tap
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapHandler(_:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.numberOfTouchesRequired = 1
        singleTap.require(toFail: doubleTap)
        imageView.addGestureRecognizer(doubleTap)
        
        // - Load image
        imageView.image = UIImage(contentsOfFile: attachment.url.path)
    }
    
    // MARK: - Public functions
    func imageForView(image: UIImage) {
        imageView.image = image
    }
}

// ImageViewerController private function
extension PreviewImageController {
    // Single tap handler
    @objc private func singleTapHandler(_ sender: UITapGestureRecognizer) {
        print("[Img preview] single tap")
        let flag = navigationController?.isNavigationBarHidden
        navigationController?.setNavigationBarHidden(!flag!, animated: true)
    }
    
    // Double tap handler
    @objc private func doubleTapHandler(_ sender: UITapGestureRecognizer) {
        print("[Img preview] double tap")
        UIView.animate(withDuration: 0.5) {
            if self.scrollView.zoomScale == self.minimumScale {
                let pointInView = sender.location(in: self.imageView)
                let scrollViewSize = self.scrollView.bounds.size
                let w = scrollViewSize.width / self.maximumScale
                let h = scrollViewSize.height / self.maximumScale
                let x = pointInView.x - (w / 2.0)
                let y = pointInView.y - (h / 2.0)
                let rectToZoomTo = CGRect(x: x, y: y, width: w, height: h)
                self.scrollView.zoom(to: rectToZoomTo, animated: true)
            }
            else {
                self.scrollView.zoomScale = self.minimumScale
            }
        }
    }
}

// MARK: - UIScrollView delegate
extension PreviewImageController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if scrollView.zoomScale > 1 {
            navigationController?.setNavigationBarHidden(true, animated: true)
            
            if let image = imageView.image {
                
                let ratioW = imageView.frame.width / image.size.width
                let ratioH = imageView.frame.height / image.size.height
                
                let ratio = ratioW < ratioH ? ratioW:ratioH
                
                let newWidth = image.size.width*ratio
                let newHeight = image.size.height*ratio
                
                let left = (newWidth * scrollView.zoomScale > imageView.frame.width ? (newWidth - imageView.frame.width) : (scrollView.frame.width - scrollView.contentSize.width)) / 2
                let top =   (newHeight * scrollView.zoomScale > imageView.frame.height ? (newHeight - imageView.frame.height) : (scrollView.frame.height - scrollView.contentSize.height)) / 2
                
                scrollView.contentInset = UIEdgeInsets.init(top: top, left: left, bottom: top, right: left)
            }
        } else {
            scrollView.contentInset = UIEdgeInsets.zero
            navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
}
