//
//  SearchViewCell.swift
//  MemoIt
//
//  Created by mk mk on 23/8/19.
//  Copyright © 2019 MC2. All rights reserved.
//

import UIKit

class SearchViewCell: UITableViewCell {

	// MARK: - Properties
	// - Constants
	// Icon size
//	private let iconSize: CGFloat = 
	
	// MARK: - Views
	// Icon view
	private lazy var iconView: UIImageView = {
		let imgV = UIImageView()
		imgV.contentMode = .scaleAspectFit
		return imgV
	}()
	
	// Title label
	private lazy var titleLabel: UILabel = {
		let lb = UILabel()
		lb.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
		lb.textColor = #colorLiteral(red: 0.370555222, green: 0.3705646992, blue: 0.3705595732, alpha: 1)
		return lb
	}()
	
	// Time label
	private lazy var timeLabel: UILabel = {
		let lb = UILabel()
		lb.font = UIFont.systemFont(ofSize: 12)
		lb.textColor = #colorLiteral(red: 0.370555222, green: 0.3705646992, blue: 0.3705595732, alpha: 1)
		return lb
	}()
	
	
	// MARK: - Custom init
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupUI()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError()
	}
}

// MARK: - Override function
extension SearchViewCell {
	override func prepareForReuse() {
		super.prepareForReuse()
		iconView.image = nil
	}
}

// MARK: -  Public function
extension SearchViewCell {
	func updateCell(memo: Memo) {
		// Set icon
		let type: MemoType = MemoType(rawValue: memo.type.rawValue)!
		switch type {
		case .attach:
			iconView.image = #imageLiteral(resourceName: "Text44").withRenderingMode(.alwaysTemplate)
			iconView.tintColor = #colorLiteral(red: 1, green: 0.8039215686, blue: 0, alpha: 0.5)
			
		case .todo:
			iconView.image = #imageLiteral(resourceName: "CheckBox44").withRenderingMode(.alwaysTemplate)
			iconView.tintColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
			
		case .voice:
			iconView.image = #imageLiteral(resourceName: "SoundWave44").withRenderingMode(.alwaysTemplate)
			iconView.tintColor = #colorLiteral(red: 1, green: 0.3176470588, blue: 0.2980392157, alpha: 1)
		}
		
		// Set title
		titleLabel.text = memo.title
		
		// Set time
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy MMM dd  HH:mm"
		timeLabel.text = formatter.string(from: memo.timeModified! as Date)
	}
}

// MARK: - Setup UI
extension SearchViewCell {
	private func setupUI(){
		// Icon view
		contentView.addSubview(iconView)
		iconView.translatesAutoresizingMaskIntoConstraints = false
		iconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
		iconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Padding.p20).isActive = true
		iconView.heightAnchor.constraint(equalToConstant: UIHelper.defaultH).isActive = true
		iconView.widthAnchor.constraint(equalTo: iconView.heightAnchor).isActive = true
		
		// Title label
		contentView.addSubview(titleLabel)
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		titleLabel.topAnchor.constraint(equalTo: iconView.topAnchor).isActive = true
		titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: Padding.p20).isActive = true
		titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -Padding.p20).isActive = true
		
		// Time label
		contentView.addSubview(timeLabel)
		timeLabel.translatesAutoresizingMaskIntoConstraints = false
		timeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Padding.p5).isActive = true
		timeLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor).isActive = true
		timeLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -Padding.p20).isActive = true
	}
}
