//
//  MKPresentationController.swift
//  ScheMo
//
//  Created by Mica Palm P/L on 13/12/18.
//  Copyright © 2018 MC2. All rights reserved.
//

import UIKit

public class MKPresentationController: UIPresentationController {
    
    // MARK: - Properties
    // - Constants
    // VC height
    public var controllerHeight: CGFloat = 0
    
    // MARK: - Views
    // Dimming view
    lazy var dimView: UIView = {
        let view = UIView()
        if let frame = self.containerView?.bounds {
            view.frame = frame
        }
        view.backgroundColor = #colorLiteral(red: 0.1298420429, green: 0.1298461258, blue: 0.1298439503, alpha: 1).withAlphaComponent(0.7)
        
        // Gesture
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissVC))
        view.addGestureRecognizer(tap)
        return view
    }()
    
    
    // MARK: - Custom init
    public override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        // Get controller height
        if case let vc as MKPresentBottomController = presentedViewController {
            self.controllerHeight = vc.controllerHeight
        }
        else {
            self.controllerHeight = UIScreen.main.bounds.height
        }
        
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }
    
    // MARK: - Override functions
    // Presentation transition will begin
    public override func presentationTransitionWillBegin() {
        dimView.alpha = 0
        containerView?.addSubview(dimView)
        UIView.animate(withDuration: 0.3) {
            self.dimView.alpha = 1
        }
    }
    
    // Dismissal transition will begin
    public override func dismissalTransitionWillBegin() {
        UIView.animate(withDuration: 0.3) {
            self.dimView.alpha = 0
        }
    }
    
    // Dismissal transition did end
    public override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            dimView.removeFromSuperview()
        }
    }
    
    // Frame of presented View
    public override var frameOfPresentedViewInContainerView: CGRect {
        return CGRect(x: 0,
                      y: UIScreen.main.bounds.height - controllerHeight,
                      width: UIScreen.main.bounds.width,
                      height: controllerHeight)
    }
}

// MARK: - Private functions
extension MKPresentationController {
    // Hide view notification
    @objc private func dismissVC() {
        NotificationCenter.default.post(name: NSNotification.Name.dismissMKPresentationBottomVC, object: nil)
    }
}

// MARK: - UIVIewController helper for present MKPresentBottomController
extension UIViewController: UIViewControllerTransitioningDelegate {
    // Present MKPresentBottom VC
    func presentMKBottom(_ controller: MKPresentBottomController, completion: (() -> Void)?) {
        controller.modalPresentationStyle = .custom
        controller.transitioningDelegate = self
        self.present(controller, animated: true, completion: completion)
    }
    
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let present = MKPresentationController(presentedViewController: presented, presenting: presenting)
        return present
    }
}
