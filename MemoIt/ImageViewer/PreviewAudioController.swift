//
//  PreviewAudioController.swift
//  ScheMo
//
//  Created by MICA17 on 4/4/19.
//  Copyright © 2019 MC2. All rights reserved.
//

import UIKit
import AVFoundation

final class PreviewAudioController: PreviewItemController {

    // MARK: - Properties
    // - Playing flag
    private var isPlaying: Bool = false
    // - Audio player
    private var audioPlayer: MKAudioPlayer!
    // - Button size
    private let btnSize: CGFloat = 88
    
    // MARK: - Views
    // - Control button
    private var controlBtn: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "Play"), for: .normal)
        button.addTarget(self, action: #selector(playAction), for: .touchUpInside)
        return button
    }()
    
    // - Progress bar
    private var progressBar: UIProgressView = {
        let pb = UIProgressView()
        pb.transform = pb.transform.scaledBy(x: 1, y: 1.5)
        pb.progressTintColor = #colorLiteral(red: 1, green: 0.4932718873, blue: 0.4739984274, alpha: 1)
        pb.trackTintColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)
        return pb
    }()
    
    // - Time label
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.textColor = #colorLiteral(red: 0.6642242074, green: 0.6642400622, blue: 0.6642315388, alpha: 1)
        label.font = UIFont.preferredFont(forTextStyle: .title3)
        label.text = "00:00:00"
        return label
    }()
    
    // MARK: - Override initializer
    override init(attachment: AttachmentModel) {
        super.init(attachment: attachment)
        guard let player = MKAudioPlayer(url: attachment.directory) else { fatalError() }
        self.audioPlayer = player
        self.audioPlayer.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError()
    }
    
    // MARK: - Override functions
    override func loadView() {
        super.loadView()
        
        let screenW = UIScreen.main.bounds.width
        let screenH = UIScreen.main.bounds.height
        let size: CGFloat = min(screenW, screenH)
        
        // Image view
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: size).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: size).isActive = true
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        imageView.backgroundColor = .white
        imageView.image = #imageLiteral(resourceName: "SoundWave").withRenderingMode(.alwaysTemplate)
        imageView.tintColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)
        
        // Control button
        controlBtn.layer.cornerRadius = btnSize / 2
        view.addSubview(controlBtn)
        controlBtn.translatesAutoresizingMaskIntoConstraints = false
        controlBtn.widthAnchor.constraint(equalToConstant: btnSize).isActive = true
        controlBtn.heightAnchor.constraint(equalToConstant: btnSize).isActive = true
        controlBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        controlBtn.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        // Time label
        view.addSubview(timeLabel)
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -Padding.p5).isActive = true
        timeLabel.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -Padding.p5).isActive = true
        
        // Progress bar
        view.addSubview(progressBar)
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        progressBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Padding.p10).isActive = true
        progressBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Padding.p10).isActive = true
        progressBar.bottomAnchor.constraint(equalTo: timeLabel.topAnchor, constant: -Padding.p5).isActive = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup duration label
        let durationStr: String = Helper.convertTimeToString(time: audioPlayer.duration)
        timeLabel.text = String(format: "00:00:00 / %@", durationStr)
    }
}

// MARK: - Private functions
extension PreviewAudioController {
    // Play action
    @objc private func playAction() {
        guard let player = audioPlayer else { return }
        player.playAction()
    }
    
    // Update duration label
    private func progress(player: AVAudioPlayer) {
        let duration = player.duration
        let currTime = player.currentTime
        let duraStr = Helper.convertTimeToString(time: duration)
        let currTmStr = Helper.convertTimeToString(time: currTime)
        timeLabel.text = String(format: "%@ / %@", currTmStr, duraStr)
        
        let progress = Float(currTime / duration)
        progressBar.progress = progress
    }
}

// MARK: - MKAudioPlayerDelegate
extension PreviewAudioController: MKAudioPlayerDelegate {
    func play() {
        controlBtn.setImage(#imageLiteral(resourceName: "Pause"), for: .normal)
    }
    
    func pause() {
        controlBtn.setImage(#imageLiteral(resourceName: "Play"), for: .normal)
    }
    
    func stop(player: AVAudioPlayer) {
        controlBtn.setImage(#imageLiteral(resourceName: "Play"), for: .normal)
        // Last update UI
        let duraStr = Helper.convertTimeToString(time: player.duration)
        timeLabel.text = String(format: "%@ / %@", duraStr, duraStr)
        progressBar.progress = 1.0
    }
    
    func update(player: AVAudioPlayer) {
        progress(player: player)
    }
}
