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

final class VoiceViewController: UIViewController {
	// MARK: - Properties
	// - Constants
	// Temperary file name
	private let tempFileName = "temp.m4a"
	// State label height
	private let stateLbH: CGFloat = 24
	// Timer label height
	private let timerLbH: CGFloat = 50
	// Record button width multiplier
	private let recordBtn_W: CGFloat = 1/3
	// Play button size
	private let playBtnSize: CGFloat = 80
	
	// - Audio recorder / player state
	// Voice recorder type
	private var recorderType: RecorderType = .voiceMemo
	// Recorder mode
	private var recorderMode: RecorderState = .ready
	// Player mode
	private var playerMode: PlayerState = .stop
	
	// - AVFoundation variables
	// Audio session
	private var session = AVAudioSession.sharedInstance()
	// Recorder
	private var recorder: AVAudioRecorder?
	// Player
	private var player: MKAudioPlayer?
	// TImer
	private var timer: CADisplayLink?
	
	// Closure
	var saveAudio: ((URL) -> Void)?
	

	// MARK: - Views
	// Save button
	private lazy var saveBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "Save44"), style: .plain, target: self, action: #selector(saveAction))
	
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
		let line = UIHelper.separator(withColor: #colorLiteral(red: 0.6642242074, green: 0.6642400622, blue: 0.6642315388, alpha: 1))
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
		btn.setImage(#imageLiteral(resourceName: "Record96").withRenderingMode(.alwaysTemplate), for: .normal)
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
		btn.setImage(#imageLiteral(resourceName: "Play64"), for: .normal)
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
		// Prepare control buttons
		saveBtn.isEnabled = false
		recordBtn.isEnabled = false
		playBtn.isEnabled = false
		
		switch self.recorderType {
		case .attachment:
			titleField.isHidden = true
		case .voiceMemo:
			titleField.isHidden = false
		}
		
		// Get microphone permission
		switch session.recordPermission {
		case .granted:
			setupSession()
			
		case .denied:
			noPermission()
			
		case .undetermined:
			session.requestRecordPermission { (granted) in
				if granted {
					self.setupSession()
				}
				else {
					self.noPermission()
				}
			}
			
		default:
			noPermission()
		}
	}
}


// MARK: - Private funcitons
extension VoiceViewController {
	
	// MARK: - Setup functions
	private func setupSession() {
		// Activate session
		do {
			try session.setCategory(.playAndRecord, options: .defaultToSpeaker)
			try session.setActive(true, options: [])
		}
		catch {
			print("\(self): Failed to activate session")
		}
		
		// Setup recorder
		setupRecorder()
	}
	
	// Setup recorder
	private func setupRecorder() {
		// Recorder setting
		let recorderSetting = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
							   AVSampleRateKey: 32000,
							   AVNumberOfChannelsKey: 1,
							   AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue]
		
		do {
			recorder = try AVAudioRecorder(url: audioURL(), settings: recorderSetting)
		} catch {
			print("Can't start recorder: ", error.localizedDescription)
			recorder = nil
			recordBtn.isEnabled = false
		}
		
		if let recorder = self.recorder {
			recorder.isMeteringEnabled = true
//			recorder.delegate = self
			recorder.prepareToRecord()
			DispatchQueue.main.async {
				self.recordBtn.isEnabled = true
			}
			
		}
	}
	
	// Setup player
	private func setupPlayer() {
		guard let player = MKAudioPlayer(url: audioURL()) else {
			fatalError("[\(self)]: Failed to init audio player")
		}
		
		self.player = player
		self.player?.delegate = self
	}
	
	// MARK: - Recorder action
	private func startRecord() {
		recorderMode = .recording
		
		// Completely stop player
		player?.stopAudio()
		playBtn.isEnabled = false
		
		// Recorder 
		guard let recorder = self.recorder else { return }
		recorderMode = .recording
		recorder.record()
		timer = CADisplayLink(target: self, selector: #selector(updateAudioMeter))
		timer?.add(to: .current, forMode: .common)
		recordBtn.setImage(#imageLiteral(resourceName: "Recording96"), for: .normal)
		recordBtn.tintColor = #colorLiteral(red: 1, green: 0.4352941176, blue: 0.4196078431, alpha: 1)
		
		saveBtn.isEnabled = false
		titleField.isEnabled = false
		titleField.resignFirstResponder()
		stateLabel.text = "Recording..."
	}
	
	private func stopRecord() {
		recorderMode = .ready
		
		// Recorder
		guard let recorder = self.recorder else { return }
		recorder.stop()
		
		recordBtn.setImage(#imageLiteral(resourceName: "Record96"), for: .normal)
		recordBtn.tintColor = #colorLiteral(red: 0.370555222, green: 0.3705646992, blue: 0.3705595732, alpha: 1)
		
		// Timer
		if let timer = self.timer {
			timer.remove(from: .current, forMode: .common)
			self.timer = nil
		}
		
		// Wave view
		waveView.update(withLevel: 0)
		
		// Other components
		playBtn.isEnabled = true
		saveBtn.isEnabled = true
		titleField.isEnabled = true
		stateLabel.text = "Ready."
	}
	
	// MARK: - Save recording to file
	private func saveAudioMemo(url : URL) {
		let fileName = url.lastPathComponent
		let memoPath = Helper.audioDirectory().appendingPathComponent(fileName)
		// Move to audio memo directory
		do {
			try FileManager.default.moveItem(at: url, to: memoPath)
		} catch {
			print("Failed to move audio record: ", error.localizedDescription)
		}
		// Clear temp directory
		Helper.clearTmpDirectory()
		
		// Audio title
		var title = "Recording"
		if let titleTxt = titleField.text,
			!titleTxt.trimmingCharacters(in: .whitespaces).isEmpty {
			title = titleTxt
		}
		
		// Save to core data
		let context = Helper.dataContext()
		// Entity
		let entity = NSEntityDescription.entity(forEntityName: "VoiceMemo", in: context)
		// Memo object
		let memoObject = NSManagedObject(entity: entity!, insertInto: context) as? VoiceMemo
		
		// Save to memo list
		Helper.addNewMemoToList(memo: memoObject!)
		
		// Set title
		memoObject?.setValue(title, forKey: "title")
		// Set modified time
		memoObject?.setValue(Date(), forKey: "timeModified")
		// Set archived flag
		memoObject?.setValue(false, forKey: "archived")
		// Set Memo ID
		memoObject?.setValue(fileName, forKey: "memoID")
		// Set Color
		memoObject?.setValue(UIColor.white, forKey: "color")
		// Set type
		memoObject?.setValue(MemoType.voice.rawValue, forKey: "type")
		
		// Save object
		do {
			try context.save()
		} catch {
			print("Error occured when save data: ", error.localizedDescription)
			return
		}
		// Clear context
		context.refreshAllObjects()
		
		// Post notification
		NotificationCenter.default.post(name: .reloadHomeList, object: nil)
	}
	
	// MARK: - Misc functions
	// Audio URL
	private func audioURL() -> URL {
		let tmpPath = FileManager.default.temporaryDirectory
		return tmpPath.appendingPathComponent(tempFileName)
	}
	
	// No permission popup
	private func noPermission() {
		let alert = UIAlertController(title: "No microphone permission",
									  message: "Please allow microphone access in \"Privacy\" setting.",
									  preferredStyle: .alert) 
		
		alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
			return
		}))
		self.present(alert, animated: true, completion: nil)
	}
	
	// Update text label
	private func updateTimeLabel(time: TimeInterval) {
		let min = Int(time / 60)
		let sec = Int(time.truncatingRemainder(dividingBy: 60))
		let minSec = Int((time.truncatingRemainder(dividingBy: 1)) * 100)
		let timeStr = String(format: "%02d:%02d.%02d", min, sec, minSec)
		timerLabel.text = timeStr
	}
}

// MARK: - Actions
extension VoiceViewController {
	// Dismiss controller actions
	@objc private func dismissController() {
		// Reset recorder
		if let recorder = self.recorder {
			recorder.stop()
			self.recorder = nil
		}
		
		// Reset player
		if let player = self.player {
			player.stopAudio()
			self.player = nil
		}
		
		// Reset timer
		if timer != nil {
			timer!.remove(from: .current, forMode: .common)
			timer = nil
		}
		
		// Dismiss controller
		navigationController?.popViewController(animated: true)
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
	
	// Play action
	@objc private func playAction() {
		if self.player == nil {
			setupPlayer()
			self.timerLabel.text = "00:00.00"
		}
		
		guard let player = self.player else { return }
		player.playAction()
	}
	
	// Long pressing action
	@objc private func longPressHandler(sender: UILongPressGestureRecognizer) {
		let state = sender.state
		if state == .began {
			recordBtn.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
			startRecord()
		}
		else if state == .ended {
			recordBtn.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
			stopRecord()
		}
	}
	
	// Update audio meter
	@objc private func updateAudioMeter() {
		
		guard let recorder = self.recorder else { return }
		let currentTime: TimeInterval = recorder.currentTime
		let normalizedValue: CGFloat = pow(10, CGFloat(recorder.averagePower(forChannel: 0))/60)
		recorder.updateMeters()
		// Update wave view
		waveView.update(withLevel: normalizedValue)
		
		// Update time label
		updateTimeLabel(time: currentTime)
	}
}

// MARK: - Delegates
// MARK: - UITextField delegate
extension VoiceViewController: UITextFieldDelegate {
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
}

// MARK: - AVAudioPlayer delegate
extension VoiceViewController: MKAudioPlayerDelegate {
	func play() {
		titleField.resignFirstResponder()
		
		playBtn.setImage(#imageLiteral(resourceName: "Pause64"), for: .normal)
		recordBtn.isEnabled = false
		saveBtn.isEnabled = false
		titleField.isEnabled = false
		// Update label
		stateLabel.text = "Playing..."
	}
	
	func pause() {
		playBtn.setImage(#imageLiteral(resourceName: "Play64"), for: .normal)
		recordBtn.isEnabled = true
		saveBtn.isEnabled = true
		titleField.isEnabled = true
	}
	
	func stop(player: AVAudioPlayer) {
		playBtn.setImage(#imageLiteral(resourceName: "Play64"), for: .normal)
		recordBtn.isEnabled = true
		saveBtn.isEnabled = true
		titleField.isEnabled = true
		waveView.update(withLevel: 0)
	}
	
	func update(player: AVAudioPlayer) {
		let normalizedValue = pow(10, CGFloat(player.averagePower(forChannel: 0))/60)
		let currTime = player.currentTime
		
		player.updateMeters()
		// Update wave view
		waveView.update(withLevel: normalizedValue)
		
		// Update time label
		updateTimeLabel(time: currTime)
	}
}

// MARK: - Setup UI
extension VoiceViewController {
	override func loadView() {
		super.loadView()
		// Navigation bar
		navigationController?.setNavigationBarHidden(false, animated: false)
		
		// - Left button
		let leftBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "NaviBack44"), style: .plain, target: self, action: #selector(dismissController))
		navigationItem.leftBarButtonItem = leftBtn
		// Right button
		navigationItem.rightBarButtonItem = saveBtn
		
		// Tint color for navigation bar
		navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.370555222, green: 0.3705646992, blue: 0.3705595732, alpha: 1)
		navigationItem.leftBarButtonItem?.tintColor = #colorLiteral(red: 0.370555222, green: 0.3705646992, blue: 0.3705595732, alpha: 1) 
		navigationItem.rightBarButtonItem?.tintColor = #colorLiteral(red: 0.370555222, green: 0.3705646992, blue: 0.3705595732, alpha: 1)
		
		// Background color
		view.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
		
		// Setup by type
		switch recorderType {
		case .attachment:
			title = ""
		case .voiceMemo:
			title = "Voice memo"		
		}
		
		// Title field
		titleField.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(titleField)
		titleField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Padding.p5).isActive = true
		titleField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: Padding.p20).isActive = true
		titleField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -Padding.p20).isActive = true
		titleField.heightAnchor.constraint(equalToConstant: UIHelper.defaultH).isActive = true
		
		// Timer label
		timerLabel.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(timerLabel)
		timerLabel.topAnchor.constraint(equalTo: titleField.bottomAnchor, constant: Padding.p40).isActive = true
		timerLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: Padding.p10).isActive = true
		timerLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -Padding.p10).isActive = true
		timerLabel.heightAnchor.constraint(equalToConstant: timerLbH).isActive = true
		
		// State label
		stateLabel.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(stateLabel)
		stateLabel.topAnchor.constraint(equalTo: timerLabel.bottomAnchor, constant: Padding.p5).isActive = true
		stateLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant:Padding.p40).isActive = true
		stateLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -Padding.p40).isActive = true
		stateLabel.heightAnchor.constraint(equalToConstant: stateLbH).isActive = true
		
		// Wave view
		waveView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(waveView)
		waveView.topAnchor.constraint(equalTo: stateLabel.bottomAnchor).isActive = true
		waveView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
		waveView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
		waveView.bottomAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
		
		// Play button
		playBtn.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(playBtn)
		playBtn.widthAnchor.constraint(equalToConstant: playBtnSize).isActive = true
		playBtn.heightAnchor.constraint(equalToConstant: playBtnSize).isActive = true
		playBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		playBtn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Padding.p100).isActive = true
		
		// Record button
		recordBtn.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(recordBtn)
		recordBtn.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: recordBtn_W).isActive = true
		recordBtn.heightAnchor.constraint(equalTo: recordBtn.widthAnchor).isActive = true
		recordBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		recordBtn.bottomAnchor.constraint(equalTo: playBtn.topAnchor, constant: -Padding.p10).isActive = true
		
		// Hints label
		let hint = UIHelper.label(font: UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.thin), textColor: #colorLiteral(red: 0.370555222, green: 0.3705646992, blue: 0.3705595732, alpha: 1))
		hint.text = "Press and hold to start record"
		hint.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(hint)
		hint.bottomAnchor.constraint(equalTo: recordBtn.topAnchor, constant: -Padding.p20).isActive = true
		hint.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
	}
}
