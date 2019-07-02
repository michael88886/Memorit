//
//  MKCircleProgress.swift
//  MemoIt
//
//  Created by mk mk on 30/6/19.
//  Copyright © 2019 MC2. All rights reserved.
//

import UIKit

class MKCircleProgress: UIView {

	
	// MARK: - Properties
	
	// - Variables
	// Once flag
	private var once: Bool = true
	
	
	// Progress color
	var progressColor: UIColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1) {
		didSet {
			progressLayer.strokeColor = progressColor.cgColor
		}
	}
	
	// Track color
	var trackColor: UIColor =  #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1) {
		didSet {
			tracklayer.strokeColor = trackColor.cgColor
		}
	}
	
	// Progress bar width
	var lineWidth:CGFloat = 10.0 {
		didSet{
			progressLayer.lineWidth = lineWidth
			tracklayer.lineWidth = lineWidth
		}
	}
	
	// Text size
	var textSize: CGFloat = 14 {
		didSet {
			percentageLabel.font = UIFont.systemFont(ofSize: textSize, weight: .medium)
		}
	}
	
	// MARK: - Views
	lazy var percentageLabel: UILabel = {
		let lb = UILabel()
		lb.textAlignment = .center
		lb.textColor = UIHelper.defaultTint
		lb.text = "0%"
		return lb
	}()
	
	// Track layer
	let tracklayer = CAShapeLayer()
	
	// Progress layer
	let progressLayer = CAShapeLayer()
}


// MARK: - Public functions
extension MKCircleProgress {
	// Reset progress
	func resetProgress() {
		progressLayer.strokeEnd = 0
		percentageLabel.text = "0%"
	}
	
	// Set progress
	func setProgress(value: CGFloat) {
		guard value <= 1.0 else { return }
		if once {
			// Force superview to calculate final size of progress view
			superview?.layoutIfNeeded()
			setupView()
			once = false
		}

		progressLayer.strokeEnd = value
		updatePercentLabel(progress: value)
	}
	
	// Animate progress
	func animationProgress(progress: CGFloat) {
		guard progress <= 1 else { return }
		if once {
			// Force superview to calculate final size of progress view
			superview?.layoutIfNeeded()
			setupView()
			once = false
		}
		
		let animation = CABasicAnimation(keyPath: "strokeEnd")
		animation.duration = 0.5
		animation.fromValue = 0
		animation.toValue = progress
		animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
		progressLayer.strokeEnd = progress
		progressLayer.add(animation, forKey: "animateCircle")
		updatePercentLabel(progress: progress)
	}
}

// MARK: - Private functions
extension MKCircleProgress {
	
	private func updatePercentLabel(progress: CGFloat) {
		let value = progress * 100
		percentageLabel.text = String(format: "%.0f %%", value)
	}
	
	private func setupView() {
		let startAngle = (-CGFloat.pi) / 2
		
		// Circle path
		let circlePath = UIBezierPath(arcCenter: CGPoint(x: bounds.width/2.0, y: bounds.height/2.0), 
									  radius: (bounds.size.width - lineWidth) / 2 , 
									  startAngle: startAngle, 
									  endAngle: 2 * CGFloat.pi + startAngle, 
									  clockwise: true)
		
		// Track layer
		tracklayer.path = circlePath.cgPath
		tracklayer.fillColor = UIColor.clear.cgColor
		tracklayer.strokeColor = trackColor.cgColor
		tracklayer.lineWidth = lineWidth
		tracklayer.strokeEnd = 1.0
		tracklayer.frame = bounds
		layer.addSublayer(tracklayer)
		
		
		// Progress layer
		progressLayer.path = circlePath.cgPath
		progressLayer.fillColor = UIColor.clear.cgColor
		progressLayer.strokeColor = progressColor.cgColor
		progressLayer.lineWidth = lineWidth
		progressLayer.strokeEnd = 0
		progressLayer.frame = bounds
		layer.addSublayer(progressLayer)
		
		// Percentage label
		percentageLabel.translatesAutoresizingMaskIntoConstraints = false
		addSubview(percentageLabel)
		percentageLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
		percentageLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
	}
}
