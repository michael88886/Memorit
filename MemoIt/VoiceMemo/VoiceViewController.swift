//
//  VoiceViewController.swift
//  MemoIt
//
//  Created by mk mk on 6/6/19.
//  Copyright © 2019 MC2. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData

// MARK: - Recorder mode
private enum RecorderMode {
	case ready
	case recording
}

// Voice recorder mode
enum RecorderType {
	case attachment
	case voiceMemo
}

class VoiceViewController: UIViewController {
	// MARK: - Properties
	// - Constants
	// Temperary file name
	let tempFileName = "temp.m4a"
	// State label height
	let stateLbH: CGFloat = 24
	// Timer label height
	let timerLbH: CGFloat = 50
	// Record button width multiplier
	let recordBtn_W: CGFloat = 1/3
	// Play button size
	let playBtnSize: CGFloat = 80
	// Title height
	let titleH: CGFloat = 44
	
	// - Audio recorder / player state
	// Voice recorder type
	private var recorderType: RecorderType = .voiceMemo
	// Recorder mode
	private var recorderMode: RecorderMode = .ready
	// Player mode
	private var playerMode: PlayerState = .stop
	
	// - AVFoundation variables
	// Audio session
	private var session: AVAudioSession!
	// Recorder
	private var recorder: AVAudioRecorder!
	// Player
	private var player: AVAudioPlayer!
	// TImer
	private var timer: Timer?
	
	
	
	// MARK: - Views
	
	
	

}


// MARK: - Override functions
extension VoiceViewController {
	override func viewDidLoad() {
		super.viewDidLoad()
		
		
	}
	
	override func loadView() {
		super.loadView()
		
		
	}
}

// MARK: - Private funcitons
extension VoiceViewController {}

// MARK: - Actions
extension VoiceViewController {}
