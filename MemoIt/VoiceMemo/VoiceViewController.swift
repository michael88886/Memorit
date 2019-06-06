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
private enum RecorderState {
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
	private var recorderMode: RecorderState = .ready
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
	
	// Closure
	var saveAudio: ((URL) -> Void)?
	

	// MARK: - Views
	// Top content view
	private lazy var topContentView = UIView()
	
	// Save button
	private lazy var saveBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "Save"), style: .plain, target: self, action: #selector(saveAction))
	
	// Title field
	private lazy var titleField: UITextField = {
		let title = UITextField()
		//        title.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
		title.borderStyle = .none
		title.font = UIFont.systemFont(ofSize: 18)
		title.textColor = #colorLiteral(red: 0.4756349325, green: 0.4756467342, blue: 0.4756404161, alpha: 1)
		title.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
		title.attributedPlaceholder = NSAttributedString(string: "Audio title ...", attributes: [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.6642242074, green: 0.6642400622, blue: 0.6642315388, alpha: 1)])
		title.delegate = self
		
		// Under line
		let line = UIHelper.separator(withColor: #colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1))
		line.translatesAutoresizingMaskIntoConstraints = false
		title.addSubview(line)
		line.heightAnchor.constraint(equalToConstant: 1).isActive = true
		line.widthAnchor.constraint(equalTo: title.widthAnchor, multiplier: 1).isActive = true
		line.centerXAnchor.constraint(equalTo: title.centerXAnchor).isActive = true
		line.bottomAnchor.constraint(equalTo: title.bottomAnchor).isActive = true
		
		return title
	}()
	
	// State label
	private lazy var stateLabel: UILabel = {
		let label = UIHelper.label(font: UIFont.systemFont(ofSize: 22), textColor: #colorLiteral(red: 1, green: 0.5725490196, blue: 0.5607843137, alpha: 1))
		label.textAlignment = .center
		label.text = "Ready"
		return label
	}()

	// Timer label
	private lazy var timerLabel: UILabel = {
		let label = UIHelper.label(font: UIFont.monospacedDigitSystemFont(ofSize: 48, weight: UIFont.Weight.light), textColor: #colorLiteral(red: 0.370555222, green: 0.3705646992, blue: 0.3705595732, alpha: 1))
		label.textAlignment = .center
		label.text = "00:00.00"
		return label
	}()
	
	// Wave view
	private lazy var waveView: SCSiriWaveformView = {
		let wvView = SCSiriWaveformView(frame: CGRect.zero)
		wvView.backgroundColor = .clear
		wvView.waveColors = [#colorLiteral(red: 1, green: 0.3176470588, blue: 0.2980392157, alpha: 1), #colorLiteral(red: 1, green: 0.4352941176, blue: 0.4196078431, alpha: 1), #colorLiteral(red: 1, green: 0.5725490196, blue: 0.5607843137, alpha: 1), #colorLiteral(red: 1, green: 0.737254902, blue: 0.7294117647, alpha: 1)]
		wvView.primaryWaveLineWidth = 2.0
		wvView.secondaryWaveLineWidth = 1.0
		wvView.update(withLevel: 0)
		return wvView
	}()
	
	// Record button
	private lazy var recordBtn: UIButton = {
		let btn = UIButton(type: .custom)
		btn.setImage(#imageLiteral(resourceName: "Record").withRenderingMode(.alwaysTemplate), for: .normal)
		btn.tintColor = #colorLiteral(red: 0.370555222, green: 0.3705646992, blue: 0.3705595732, alpha: 1)
		// Long press gesture
		let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressHandler(sender:)))
		longPress.minimumPressDuration = 0.0
		btn.addGestureRecognizer(longPress)
		return btn
	}()
	
	// Play button
	private lazy var playBtn: UIButton = {
		let btn = UIButton(type: .custom)
		btn.setImage(#imageLiteral(resourceName: "Play"), for: .normal)
		btn.addTarget(self, action: #selector(playAction), for: .touchUpInside)
		return btn
	}()
	
	
	// MARK: - Convenience init
	convenience init(type: RecorderType) {
		self.init()
		self.recorderType = type
	}
	
}


// MARK: - Override functions
extension VoiceViewController {
	override func viewDidLoad() {
		super.viewDidLoad()
		
		
	}
	
	override func loadView() {
		super.loadView()
		// Navigation bar
		// - Left button
		let leftBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "NaviBack"), style: .plain, target: self, action: #selector(dismissController))
		navigationController?.navigationItem.leftBarButtonItem = leftBtn
		// Right button
		navigationController?.navigationItem.rightBarButtonItem = saveBtn
		
		// Background color
		view.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
		
		// Content view
		topContentView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(topContentView)
		topContentView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
		topContentView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
		topContentView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
		topContentView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
		
		// Timer label
		timerLabel.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(timerLabel)
		timerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: UIHelper.Padding.p20).isActive = true
		timerLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: UIHelper.Padding.p10).isActive = true
		timerLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -UIHelper.Padding.p10).isActive = true
		timerLabel.heightAnchor.constraint(equalToConstant: timerLbH).isActive = true
		
		// State label
		stateLabel.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(stateLabel)
		stateLabel.topAnchor.constraint(equalTo: timerLabel.bottomAnchor, constant: UIHelper.Padding.p5).isActive = true
		stateLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: UIHelper.Padding.p40).isActive = true
		stateLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -UIHelper.Padding.p40).isActive = true
		stateLabel.heightAnchor.constraint(equalToConstant: stateLbH).isActive = true
		
		// Wave view
		waveView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(waveView)
		waveView.topAnchor.constraint(equalTo: stateLabel.bottomAnchor).isActive = true
		waveView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
		waveView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
		waveView.bottomAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
		
		// Title field
		titleField.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(titleField)
		titleField.topAnchor.constraint(equalTo: waveView.bottomAnchor, constant: UIHelper.Padding.p20).isActive = true
		titleField.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: UIHelper.Padding.p20).isActive = true
		titleField.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -UIHelper.Padding.p20).isActive = true
		titleField.heightAnchor.constraint(equalToConstant: titleH).isActive = true
		
		
		// Hints label
		let hint = UIHelper.label(font: UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.thin), textColor: #colorLiteral(red: 0.370555222, green: 0.3705646992, blue: 0.3705595732, alpha: 1))
		hint.text = "Press and hold to start record"
		hint.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(hint)
		hint.topAnchor.constraint(equalTo: titleField.bottomAnchor, constant: UIHelper.Padding.p20).isActive = true
		hint.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		
		// Record button
		recordBtn.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(recordBtn)
		recordBtn.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: recordBtn_W).isActive = true
		recordBtn.heightAnchor.constraint(equalTo: recordBtn.widthAnchor).isActive = true
		recordBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		recordBtn.topAnchor.constraint(equalTo: hint.bottomAnchor, constant: UIHelper.Padding.p10).isActive = true
		
		// Play button
		playBtn.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(playBtn)
		playBtn.widthAnchor.constraint(equalToConstant: playBtnSize).isActive = true
		playBtn.heightAnchor.constraint(equalToConstant: playBtnSize).isActive = true
		playBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		playBtn.topAnchor.constraint(equalTo: recordBtn.bottomAnchor, constant: UIHelper.Padding.p20).isActive = true

		
		
	}
}

// MARK: - Private funcitons
extension VoiceViewController {
	
	// MARK: - Misc functions
	// Audio URL
	private func audioURL() -> URL {
		let tmpPath = FileManager.default.temporaryDirectory
		return tmpPath.appendingPathComponent(tempFileName)
	}
}

// MARK: - Actions
extension VoiceViewController {
	// Dismiss controller actions
	@objc private func dismissController() {
		// Reset recorder
		if recorder != nil {
			recorder.stop()
			recorder = nil
		}
		
		// Reset player
		if player != nil {
			player.stop()
			player = nil
		}
		
		// Reset timer
		if timer != nil {
			timer!.invalidate()
			timer = nil
		}
		
		// Dismiss controller
		dismiss(animated: true, completion: nil)
	}
	
	// Save action
	@objc private func saveAction() {
		// Save audio file to temperary directory
		let path = FileManager.default.temporaryDirectory
		let filename = Helper.uniqueName()
		var voiceFile = path.appendingPathComponent(filename)
		voiceFile.appendPathExtension("m4a")
		
		do {
			// Rename file
			try FileManager.default.moveItem(at: audioURL(), to: voiceFile)
		} catch {
			print("Failed to save voice file: ", error.localizedDescription)
			return
		}
		
		// Save audio
		switch recorderType {
		case .attachment:
			self.saveAudio?(voiceFile)
		case .voiceMemo:
			saveAudioMemo(url: voiceFile)
		}
		dismissController()
	}
}

// MARK: - Delegates
// MARK: - UITextField delegate
extension VoiceViewController: UITextFieldDelegate {
	
}
