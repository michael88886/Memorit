//
//  ImagePageViewController.swift
//  ScheMo
//
//  Created by MICA17 on 17/11/18.
//  Copyright © 2018 MC2. All rights reserved.
//

import UIKit
import AVFoundation

// MARK: - Image page viewe VC
class PreviewPageViewController: UIPageViewController {

    // MARK: - Properties
    // Current index of preview item controller
    private var currentIndex: Int = 0
    // Preview controller array
    private lazy var previewItemControllers: [PreviewItemController] = []
    
    // MARK: - Convenience init
    convenience init(attachments: [MemoAttachment], selectedIndex: Int) {
        self.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [UIPageViewController.OptionsKey.interPageSpacing: 10])
        
        // Current index
        self.currentIndex = selectedIndex
        
        // Add preview items
        for item in attachments {
            switch item.type {
            case .image:
                let vc = PreviewImageController(attachment: item)
                previewItemControllers.append(vc)
            case .audio:
                let vc = PreviewAudioController(attachment: item)
                previewItemControllers.append(vc)
            }
        }
    }

    // MARK: - Override functions
    override func loadView() {
        super.loadView()
        view.backgroundColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)
        
        // Setup naigation bar
        setupNavi()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        
        guard !previewItemControllers.isEmpty else { return }
        updateTitle()
        
        let currentVC = previewItemControllers[currentIndex]
        setViewControllers([currentVC],
                           direction: .forward,
                           animated: false, completion: nil)
        
        // Start audio session
        do {
            // Setup session
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            // Activate session
            try AVAudioSession.sharedInstance().setActive(true, options: [])
        }
        catch {
            print(error.localizedDescription)
        }
    }
}

// MARK: - ImagePageViewController private functions
extension PreviewPageViewController {
    
    @objc private func dismissController(sender: UIBarButtonItem) {
        // Deactivate audio session
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: [])
        } catch {
            print(error.localizedDescription)
        }
        
        dismiss(animated: true, completion: nil)
    }
        
    private func setupNavi() {
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        
        // Left btn
        let leftBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "NaviBack"), style: .plain, target: self, action: #selector(dismissController(sender:)))
        leftBtn.tintColor = .black
        navigationItem.leftBarButtonItem = leftBtn
    }
    
    private func updateTitle() {
        title = String(format: "%i of %i", currentIndex + 1, previewItemControllers.count)
    }
}

// MARK: - UIPageViewController data source
extension PreviewPageViewController: UIPageViewControllerDataSource {
    // Previous
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let vcIndex = previewItemControllers.firstIndex(of: viewController as! PreviewItemController) else { return nil }
        let previousIndex = vcIndex - 1
        guard previousIndex >= 0 else { return nil }
        guard previewItemControllers.count > previousIndex else { return nil }
        return previewItemControllers[previousIndex]
    }
    
    // After
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let vcIndex = previewItemControllers.firstIndex(of: viewController as! PreviewItemController) else { return nil }
        let nextIndex = vcIndex + 1
        guard previewItemControllers.count != nextIndex else { return nil }
        guard previewItemControllers.count > nextIndex else { return nil }
        return previewItemControllers[nextIndex]
    }
}

// MARK: - UIPageViewController delegate
extension PreviewPageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        print("finished update")
        
        guard completed else { return }
        if let firstVC = viewControllers?.first {
            currentIndex = previewItemControllers.firstIndex(of: firstVC as! PreviewItemController)!
            updateTitle()
        }
    }
}
