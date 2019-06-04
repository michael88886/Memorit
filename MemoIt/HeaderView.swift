//
//  HeaderView.swift
//  MemoIt
//
//  Created by mk mk on 2/6/19.
//  Copyright © 2019 MC2. All rights reserved.
//

import UIKit

class HeaderView: UIView {

	// MARK: - Properties	
	// - Constant
	let searchBarH: CGFloat = 44
	
	
	// MARK: - Views
	private lazy var imageView: UIImageView = {
		let img = UIImageView()
		img.contentMode = .scaleAspectFill
		img.clipsToBounds = true
		return img
	}()
	
	// - Canvas view
	private lazy var canvas: UIView = {
		let canv = UIView()
		canv.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.2)
		canv.isUserInteractionEnabled = false
		return canv
	}()
	
	// - Search container
	private lazy var searchUnderlay: UIView = {
		let sul = UIView()
		sul.isUserInteractionEnabled = false
		sul.layer.shadowOffset = CGSize(width: 0, height: 2)
		sul.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
		sul.layer.shadowOpacity = 0.3
		sul.layer.shadowRadius = 4.0
		return sul
	}()
	
	// - Search bar
	lazy var searchbar: UISearchBar = {
		let sb = UISearchBar()
		sb.placeholder = "Search memo"
		sb.searchBarStyle = .minimal
		sb.tintColor = #colorLiteral(red: 0.370555222, green: 0.3705646992, blue: 0.3705595732, alpha: 1)
		sb.barTintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
		sb.backgroundImage = UIImage()
		
		// Text field
		let textfield = sb.value(forKey: "searchField") as? UITextField
		if let textfield = textfield {
			textfield.borderStyle = .none
			textfield.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.7)
			textfield.clipsToBounds = true
			textfield.layer.cornerRadius = 8  //textfield.frame.height / 4
			
			let searchIcon = UIImageView(image: #imageLiteral(resourceName: "SearchIcon24").withRenderingMode(.alwaysTemplate))
			searchIcon.tintColor = #colorLiteral(red: 0.6642242074, green: 0.6642400622, blue: 0.6642315388, alpha: 1)
			searchIcon.contentMode = .center
			
			var iconSize = searchIcon.image!.size
			iconSize.width += 10
			searchIcon.frame.size = iconSize
			
			textfield.leftView = searchIcon
		}

		return sb
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

// MARK: - Public functions
extension HeaderView {
	func updateImage(image: UIImage) {
		DispatchQueue.main.async {
			self.imageView.image = image
		}
	}
	
	// Update search underlay alpha (to show background color and shadow)
	func updateAlpha(alpha: CGFloat) {
		self.searchUnderlay.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).withAlphaComponent(alpha)
	}
	
}

// MARK: - Private functions
extension HeaderView {
	// Load view
	private func loadView() {
		
		// Image view
		imageView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(imageView)
		imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
		imageView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
		imageView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
		imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
		imageView.image = #imageLiteral(resourceName: "BGwork")
		
		// Canvas
		canvas.translatesAutoresizingMaskIntoConstraints = false
		addSubview(canvas)
		canvas.topAnchor.constraint(equalTo: topAnchor).isActive = true
		canvas.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
		canvas.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
		canvas.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
		
		// Search container
		searchUnderlay.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).withAlphaComponent(0.0)
		searchUnderlay.translatesAutoresizingMaskIntoConstraints = false
		addSubview(searchUnderlay)
		searchUnderlay.topAnchor.constraint(equalTo: topAnchor).isActive = true
		searchUnderlay.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
		searchUnderlay.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
		searchUnderlay.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
		
		// Search bar
		searchbar.translatesAutoresizingMaskIntoConstraints = false
		addSubview(searchbar)
		searchbar.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor).isActive = true
		searchbar.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor).isActive = true
		searchbar.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
		searchbar.heightAnchor.constraint(equalToConstant: searchBarH).isActive = true
	}
}

