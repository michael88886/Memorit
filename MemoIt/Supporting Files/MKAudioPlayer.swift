//
//  MKAudioPlayer.swift
//  ScheMo
//
//  Created by MICA17 on 8/4/19.
//  Copyright © 2019 MC2. All rights reserved.
//

import Foundation
import AVFoundation

protocol MKAudioPlayerDelegate: class {
    // Notify start play
    func play()
    // Notify pause play
    func pause()
    // Notify stop play
    func stop(player: AVAudioPlayer)
    // Notify update
    func update(player: AVAudioPlayer)
}

// Audio player state
enum PlayerState {
	case stop
	case play
	case pause
}

final class MKAudioPlayer: NSObject {
    
    // Audio player
    private var player: AVAudioPlayer?
    // Player state
    private var state: PlayerState = .stop
    // Display link
    private var displayLink: CADisplayLink?
    // Audio duration
    var duration: TimeInterval {
        guard let playerDuration = player?.duration else { return 0 }
        return playerDuration
    }
    // Delegate
    weak var delegate: MKAudioPlayerDelegate?
    
    // Custom init
    init?(url: URL) {
        super.init()
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = self
            player?.isMeteringEnabled = true
            player?.prepareToPlay()
        } catch {
            print("Failed to create audio player: ", error.localizedDescription)
            return nil
        }
    }
    
    // Public functions
    @objc func playAction() {
        switch state {
        case .play:
            pause()
        case .pause:
            play()
        case .stop:
            play()
        }
    }
    
    func stopAudio() {
        guard let player = self.player else { return }
        self.stop(player: player)
    }
}

// MARK: - Private function
extension MKAudioPlayer {
    // Play audio
    private func play() {
        // Set state
        state = .play
        // Player action
        self.player?.play()
        // Call delegate method
        delegate?.play()
        
        // Diaplay link
        if displayLink != nil {
            // Re-start display link
            displayLink?.isPaused = false
        }
        else {
            displayLink = CADisplayLink(target: self, selector: #selector(update))
            displayLink?.add(to: .current, forMode: .common)
        }
    }
    
    // Pause audio
    private func pause() {
        // Set state
        state = .pause
        // Player action
        self.player?.pause()
        // Call delegate method
        delegate?.pause()
        
        // Pause display link
        if displayLink != nil { displayLink?.isPaused = true }
    }
    
    // Stop audio
    private func stop(player: AVAudioPlayer) {
        // Set state
        state = .stop
        // Player action
        self.player?.stop()
        // Call delegate method
        delegate?.stop(player: player)
        
        // Stop and remove display link
        if displayLink != nil {
            displayLink?.remove(from: .current, forMode: .common)
            displayLink = nil
        }
    }
    
    // Periodic update current time
    @objc private func update() {
        guard let player = player else { return }
        // Call delegate method
        delegate?.update(player: player)
    }
}

// MARK: - AVAudioPlayerDelegate
extension MKAudioPlayer: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stop(player: player)
    }
}
