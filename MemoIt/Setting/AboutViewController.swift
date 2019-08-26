//
//  AboutViewController.swift
//  MemoIt
//
//  Created by mk mk on 25/8/19.
//  Copyright © 2019 MC2. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {

	override func loadView() {
		super.loadView()
		view.backgroundColor = .white
		
		let logo = UIImageView(image: #imageLiteral(resourceName: "Memoit"))
		logo.contentMode = .scaleAspectFit
		view.addSubview(logo)
		logo.translatesAutoresizingMaskIntoConstraints = false
		logo.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		logo.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
		logo.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5).isActive = true
		logo.heightAnchor.constraint(equalTo: logo.widthAnchor).isActive = true
		
		if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String, 
			let build =  Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
			let versionLabel = UILabel()
			versionLabel.font = UIFont.systemFont(ofSize: 16, weight: .light)
			versionLabel.textAlignment = .center
			versionLabel.text = String(format: "Version %@ (%@)", version, build) 
			view.addSubview(versionLabel)
			versionLabel.translatesAutoresizingMaskIntoConstraints = false
			versionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
			versionLabel.topAnchor.constraint(equalTo: logo.bottomAnchor, constant: Padding.p10).isActive = true
		}
		
		// Credit label
		let credit = UILabel()
		credit.font = UIFont.systemFont(ofSize: 14)
		credit.textAlignment = .center
		credit.numberOfLines = 2
		credit.text = "Create by: \n Michael H @ MC2"
		view.addSubview(credit)
		credit.translatesAutoresizingMaskIntoConstraints = false
		credit.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		credit.topAnchor.constraint(equalTo: view.topAnchor, constant: Padding.p40).isActive = true
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		let tap = UITapGestureRecognizer(target: self, action: #selector(dimissAction))
		tap.numberOfTouchesRequired = 1
		view.addGestureRecognizer(tap)
	}
	
	@objc private func dimissAction() {
		dismiss(animated: true, completion: nil)
	}
}




// MARK: - Setup UI
extension AboutViewController {
	}
