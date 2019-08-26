//
//  ColorPickerView.swift
//  MemoIt
//
//  Created by mk mk on 2/8/19.
//  Copyright © 2019 MC2. All rights reserved.
//

import UIKit

class ColorPickerView: UIView {

	// MARK: - Properties
	// - Constants
	// Cell ID
	private let cellId = "ColorCell"
	// Color list
	private let colorList: [UIColor] = [#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1), #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1), #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1), #colorLiteral(red: 1, green: 0.4932718873, blue: 0.4739984274, alpha: 1), #colorLiteral(red: 0.6642242074, green: 0.6642400622, blue: 0.6642315388, alpha: 1)]

	// - Closure
	var selectColor: ((UIColor) -> Void)?
	var backToKeyboard: (() -> Void)?
	
	// MARK: - Views
	// Collection view
	private lazy var colorCollection: UICollectionView = {
		let layout = UICollectionViewFlowLayout()
		layout.scrollDirection = .horizontal
		layout.minimumLineSpacing = 10
		layout.minimumInteritemSpacing = 10
		layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
		layout.itemSize = CGSize(width: 50, height: 50) 
		
		let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
		cv.backgroundColor = .white
		cv.allowsMultipleSelection = false
		cv.delegate = self
		cv.dataSource = self
		cv.register(UICollectionViewCell.self, forCellWithReuseIdentifier: cellId)
		return cv
	}()
	
	// MARK: - Custom init
	override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError()
	}
}

// MARK: - Actions
extension ColorPickerView {
	// Go back action
	@objc private func goBackAction() {
		self.backToKeyboard?()
	}
}

// MARK: - Delegates
// MARK: - UICollectionView data source / delegate
extension ColorPickerView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	// Number of cells
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return colorList.count
	}
	
	// Setup cell
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath)
		cell.backgroundColor = colorList[indexPath.row]
		cell.layer.cornerRadius = 6.0
		cell.layer.borderColor = #colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1)
		cell.layer.borderWidth = 1.0
		return cell
	}
	
	// Select cell
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		self.selectColor?(colorList[indexPath.row])
	}
	
	// Cell size
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else { return CGSize(width: 50, height: 50) }
		let width = (collectionView.bounds.width - (7 * layout.minimumLineSpacing)) / 6
		let height = (collectionView.bounds.height - (2 * layout.minimumLineSpacing)) / 2
		return CGSize(width: width, height: height)
	}
}

// MARK: - Setup UI
extension ColorPickerView {
	private func setup() {
		backgroundColor = .white
				
		// Go back button
		let goBackBtn = UIButton(type: .custom)
		goBackBtn.setImage(#imageLiteral(resourceName: "GoBack").withRenderingMode(.alwaysTemplate), for: .normal)
		goBackBtn.tintColor = #colorLiteral(red: 0.7540688515, green: 0.7540867925, blue: 0.7540771365, alpha: 1)
		goBackBtn.addTarget(self, action: #selector(goBackAction), for: .touchUpInside)
		addSubview(goBackBtn)
		goBackBtn.translatesAutoresizingMaskIntoConstraints = false
		goBackBtn.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
		goBackBtn.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
		goBackBtn.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
		goBackBtn.heightAnchor.constraint(equalToConstant: UIHelper.defaultH).isActive = true
				
		// Collection view
		addSubview(colorCollection)
		colorCollection.translatesAutoresizingMaskIntoConstraints = false
		colorCollection.topAnchor.constraint(equalTo: topAnchor).isActive = true
		colorCollection.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
		colorCollection.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
		colorCollection.bottomAnchor.constraint(equalTo: goBackBtn.topAnchor).isActive = true
	}
}
