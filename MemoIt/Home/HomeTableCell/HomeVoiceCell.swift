//
//  HomeVoiceCell.swift
//  MemoIt
//
//  Created by mk mk on 11/6/19.
//  Copyright © 2019 MC2. All rights reserved.
//

import UIKit
import AVFoundation

class HomeVoiceCell: HomeCell {
	
	// MARK: - Properties
	// - Variables
	// Audio player
	private var player: MKAudioPlayer?
	// Playing cell
	var playingCell: ((HomeVoiceCell) -> Void)?
	
	// MARK: - Views
	// Player button
	private lazy var playBtn: UIButton = {
		let btn = UIButton(type: .custom)
		btn.setImage(#imageLiteral(resourceName: "Play64"), for: .normal)
		btn.addTarget(self, action: #selector(playAction), for: .touchUpInside)
		return btn
	}()
	
	// Duaration label
	private lazy var durationLabel: UILabel = {
		let lb = UILabel()
		lb.textAlignment = .left
		lb.textColor = UIHelper.defaultTint
		lb.font = UIFont.systemFont(ofSize: 18, weight: .regular)
		lb.text = "00:00:00 / 00:00:00"
		return lb
	}()
	
	// Progress bar
	private lazy var progressBar: UIProgressView = {
		let pb = UIProgressView()
		pb.progressTintColor = #colorLiteral(red: 1, green: 0.6146565797, blue: 0.6, alpha: 1)
		pb.trackTintColor = #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)
		return pb
	}()
	
	// MARK: - Override function
	override func prepareForReuse() {
		super.prepareForReuse()
		
		if let player = self.player {
			player.stopAudio()
		}
		player = nil
		playBtn.setImage(#imageLiteral(resourceName: "Play64"), for: .normal)
		durationLabel.text = "00:00:00 / 00:00:00"
		progressBar.progress = 0
	}
	
	override func feedCell(model: MemoModel) {
		super.feedCell(model: model)
		// Voice model
		guard let voiceModel = model as? VoiceModel else { return }
		// File URL, Player
		guard let url = voiceModel.audioURL, 
			let player = MKAudioPlayer(url: url) else { return }
		player.delegate = self
		self.player = player
		
		// Update duration text
		let duraStr = Helper.convertTimeToString(time: player.duration)
		durationLabel.text = String(format: "00:00:00 / %@", duraStr)
	}
	
}

// MARK: - Actions
extension HomeVoiceCell {
	// Play action
	@objc private func playAction() {
		guard let player  = self.player else { return }
		player.playAction()
	}
	
}

// MARK: - Cell UI
extension HomeVoiceCell {
	override func setup() {
		super.setup()
		
		// Info Container
		let infoCont = UIView()
		infoCont.translatesAutoresizingMaskIntoConstraints = false
		container.addSubview(infoCont)
		infoCont.topAnchor.constraint(equalTo: titleView.bottomAnchor).isActive = true
		infoCont.leftAnchor.constraint(equalTo: container.leftAnchor).isActive = true
		infoCont.rightAnchor.constraint(equalTo: container.rightAnchor).isActive = true
		infoCont.bottomAnchor.constraint(equalTo: container.bottomAnchor).isActive = true
		
		// Play button
		playBtn.layer.cornerRadius = UIHelper.defaultH / 2
		playBtn.translatesAutoresizingMaskIntoConstraints = false
		infoCont.addSubview(playBtn)
		playBtn.widthAnchor.constraint(equalToConstant: UIHelper.defaultH).isActive = true
		playBtn.heightAnchor.constraint(equalToConstant: UIHelper.defaultH).isActive = true
		playBtn.centerYAnchor.constraint(equalTo: infoCont.centerYAnchor).isActive = true
		playBtn.rightAnchor.constraint(equalTo: infoCont.rightAnchor, constant: -Padding.p20).isActive = true
		
		// Duration label
		durationLabel.translatesAutoresizingMaskIntoConstraints = false
		infoCont.addSubview(durationLabel)
		durationLabel.leftAnchor.constraint(equalTo: infoCont.leftAnchor, constant: Padding.p20).isActive = true
		durationLabel.bottomAnchor.constraint(equalTo: infoCont.centerYAnchor).isActive = true
		
		// Progress bar
		progressBar.translatesAutoresizingMaskIntoConstraints = false
		infoCont.addSubview(progressBar)
		progressBar.leftAnchor.constraint(equalTo: durationLabel.leftAnchor).isActive = true
		progressBar.rightAnchor.constraint(equalTo: playBtn.leftAnchor, constant: -Padding.p20).isActive = true
		progressBar.topAnchor.constraint(equalTo: durationLabel.bottomAnchor, constant: Padding.p5).isActive = true
	}
}

// MARK: - MKAudioPlayer delegate
extension HomeVoiceCell: MKAudioPlayerDelegate {
	func play() {
		// Update button image
		playBtn.setImage(#imageLiteral(resourceName: "Pause64"), for: .normal)
		playingCell?(self)
	}
	
	func pause() {
		// Update button image
		playBtn.setImage(#imageLiteral(resourceName: "Play64"), for: .normal)
	}
	
	func stop(player: AVAudioPlayer) {
		let duraStr = Helper.convertTimeToString(time: player.duration)
		// Reset duration label
		durationLabel.text = String(format: "00:00:00 / %@", duraStr)
		// Reset progress bar
		progressBar.progress = 0
		// Update button image
		playBtn.setImage(#imageLiteral(resourceName: "Play64"), for: .normal)
	}
	
	func update(player: AVAudioPlayer) {
		let dura = player.duration
		let curr = player.currentTime
		let duraStr = Helper.convertTimeToString(time: dura)
		let currStr = Helper.convertTimeToString(time: curr)
		// Update duration label
		durationLabel.text = String(format: "%@ / %@", currStr, duraStr)
		// Update progress bar
		progressBar.progress = Float(curr / dura)
	}
	
	
}
