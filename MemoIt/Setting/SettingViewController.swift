//
//  SettingViewController.swift
//  MemoIt
//
//  Created by mk mk on 25/8/19.
//  Copyright © 2019 MC2. All rights reserved.
//

import UIKit
import CoreData
import MessageUI
import StoreKit

class SettingViewController: UIViewController {

	// MARK: - Properties
	// Setting option
	private enum SettingOption {
		case note
		case todo
		case voice
		case home
		case bin
		case feedback
		case rate
		
		// Option name
		func name() -> String {
			switch self {
			case .note:     return "Note"
			case .todo:     return "Todo list"
			case .voice:    return "Voice record"
			case .home:     return "Home"
			case .bin:      return "Bin"
			case .feedback: return "Feedback & suggestion"
			case .rate:     return "Rate this app"
			}
		}
		
		// Option icon
		func icon() -> UIImage {
			switch self {
			case .note:     return #imageLiteral(resourceName: "Text44").withRenderingMode(.alwaysTemplate)
			case .todo:     return #imageLiteral(resourceName: "CheckBox44").withRenderingMode(.alwaysTemplate)
			case .voice:    return #imageLiteral(resourceName: "SoundWave44").withRenderingMode(.alwaysTemplate)
			case .home:     return #imageLiteral(resourceName: "Home").withRenderingMode(.alwaysTemplate)
			case .bin:      return #imageLiteral(resourceName: "Bin44").withRenderingMode(.alwaysTemplate)
			case .feedback: return #imageLiteral(resourceName: "Feedback").withRenderingMode(.alwaysTemplate)
			case .rate:     return #imageLiteral(resourceName: "Star").withRenderingMode(.alwaysTemplate)
			}
		}
		
		// Icon tint
		func tint() -> UIColor {
			switch self {
			case .note:  return #colorLiteral(red: 1, green: 0.8039215686, blue: 0, alpha: 1)
			case .todo:  return #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
			case .voice: return #colorLiteral(red: 1, green: 0.3176470588, blue: 0.2980392157, alpha: 1)
			default:     return #colorLiteral(red: 0.370555222, green: 0.3705646992, blue: 0.3705595732, alpha: 1)
			}
		}
	}
	
	// - Contansts
	// Cell id
	private let cellId = "SettingCell"
	
	
	// - Variables
	// Setting title list
	private let settingList = [[SettingOption.note, 
								SettingOption.todo, 
								SettingOption.voice], 
							   [SettingOption.home, 
								SettingOption.bin], 
								[SettingOption.feedback, 
								 SettingOption.rate]] 
	
	// Notes count
	private var noteCount = 0
	// Todo count
	private var todoCount = 0
	// Voice count
	private var voiceCount = 0
	// Fetch result
	private var fetchResult: NSPersistentStoreAsynchronousResult? = nil
	
	
	// MARK: - Views
	// Setting table
	private lazy var settingTable: UITableView = {
		let st = UITableView(frame: .zero, style: .grouped)
		st.rowHeight = UIHelper.defaultH
		st.allowsMultipleSelection = false
		return st
	}()
}


// MARK: - OVerride funciton
extension SettingViewController {
	override func viewDidLoad() {
		super.viewDidLoad()
		fetchData()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		fetchResult?.cancel()
	}
}

// MARK: - Private function
extension SettingViewController {
	// Fetch data
	private func fetchData() {
		// Data context
		let context = Helper.dataContext()
		// Fetch request
		let fetchRequest = NSFetchRequest<Memo>(entityName: "Memo")
		fetchRequest.predicate = NSPredicate(format: "archived == %@", NSNumber(value: false))
		
		// Asynchronnous fetch
		let asynFetchequest = NSAsynchronousFetchRequest(fetchRequest: fetchRequest) { (asychronousFetchResult) in
			guard let result = asychronousFetchResult.finalResult else { return }
			
			DispatchQueue.main.async {
				self.updateCounter(list: result)
				self.settingTable.reloadData()
			}
		}
		
		// Excute fetching
		do {
			fetchResult = try context.execute(asynFetchequest) as? NSPersistentStoreAsynchronousResult
		}
		catch {
			print("[\(self): Failed to fetch data]")
		}
	}
	
	private func updateCounter(list: [Memo]) {
		for data in list {
			let type: MemoType = MemoType(rawValue: data.type.rawValue)!			
			switch type {
			case .attach: noteCount += 1
			case .todo:   todoCount += 1
			case .voice:  voiceCount += 1
			}
		}
	}
	
	// Setup navigation view
	private func naviTitleView() -> UIView {
		// Logo
		let logo = UIImageView(image: #imageLiteral(resourceName: "Logo"))
		logo.contentMode = .scaleAspectFit
		
		// Text
		let title = UILabel()
		title.font = UIFont.systemFont(ofSize: 24)
		title.text = "Memorit"
		
		let titleView = UIStackView(arrangedSubviews: [logo, title])
		titleView.axis = .horizontal
		titleView.distribution = .fill
		titleView.alignment = .center
		titleView.spacing = 10
		return titleView
	}  
}

// MARK: - Actions
extension SettingViewController {
	// Send feedback action
	@objc private func sendEmail() {
		if MFMailComposeViewController.canSendMail() {
			let mailVC = MFMailComposeViewController()
			mailVC.mailComposeDelegate = self
			mailVC.setToRecipients(["memoritappaus@gmail.com"])
			mailVC.setSubject("Memorit app feedback / suggestion")
			present(mailVC, animated: true, completion: nil)
		}
	}
	
	// Rate app action
	@objc private func rateAppAction() {
		SKStoreReviewController.requestReview()
	}
}

// MARK: - Delegate
// MARK: - UITableView data source / delegate
extension SettingViewController: UITableViewDataSource, UITableViewDelegate {
	func numberOfSections(in tableView: UITableView) -> Int {
		return settingList.count
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return settingList[section].count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! SettingCell
		
		let data = settingList[indexPath.section][indexPath.row]
		cell.setIcon(image: data.icon())
		cell.setTint(color: data.tint())
		cell.setTitle(text: data.name())
		
		switch data {
		case .note:  cell.setSublabel(text: String(noteCount))
		case .todo:  cell.setSublabel(text: String(todoCount))
		case .voice: cell.setSublabel(text: String(voiceCount))
		default: ()
		}
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let data = settingList[indexPath.section][indexPath.row]
		
		DispatchQueue.main.async {
			switch data {
			case .home:     self.dismiss(animated: true, completion: nil)
			case .bin:      self.navigationController?.pushViewController(BinViewController(), animated: true)
			case .feedback:	self.sendEmail()
			case .rate:     self.rateAppAction()
				
			default: ()
			}
		}
	}
}

// MARK: - MFMailComposeViewControllerDelegate
extension SettingViewController: MFMailComposeViewControllerDelegate {
	func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
		controller.dismiss(animated: true, completion: nil)
	}
}

// MARK: - SetupUI
extension SettingViewController {
	override func loadView() {
		super.loadView()
		// Background color
		view.backgroundColor = .white
		
		// Navigation bar
		navigationController?.setNavigationBarHidden(false, animated: false)
		navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
		
		// Ttile View
		navigationItem.titleView = naviTitleView()
		
		// Setting table
		settingTable.delegate = self
		settingTable.dataSource = self
		settingTable.register(SettingCell.self, forCellReuseIdentifier: cellId)
		view.addSubview(settingTable)
		settingTable.translatesAutoresizingMaskIntoConstraints = false
		settingTable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
		settingTable.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
		settingTable.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
		settingTable.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
	}
}





// MARK: - Setting cell
class SettingCell: UITableViewCell {
	// MARK: - Properties
	// - Constants
	// Icon size
	private let iconSize = CGSize(width: 32, height: 32) 
	
	// MARK: - View
	// Icon
	private lazy var icon = UIImageView() 
	
	// Main labal
	private lazy var mainLabel: UILabel = {
		let lb = UILabel()
		lb.font = UIFont.systemFont(ofSize: 18)
		return lb
	}()
	
	// Sub label
	private lazy var subLabel: UILabel = {
		let lb = UILabel()
		lb.font = UIFont.systemFont(ofSize: 16)
		lb.textColor = #colorLiteral(red: 0.4756349325, green: 0.4756467342, blue: 0.4756404161, alpha: 1)
		lb.textAlignment = .right
		return lb
	}()
	
	// MARK: - Override init
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupUI()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError()
	}
}

// MARK: - Override funcion
extension SettingCell {
	override func prepareForReuse() {
		super.prepareForReuse()
		icon.image = nil
		mainLabel.text = ""
		subLabel.text = ""
	}
}

// MARK: - Public functions
extension SettingCell {
	// Set icon
	func setIcon(image: UIImage) {
		icon.image = image
	}

	// Set icon tint
	func setTint(color: UIColor) {
		icon.tintColor = color
	}
	
	// Set title
	func setTitle(text: String) {
		mainLabel.text = text
	}
	
	// Set sub label
	func setSublabel(text: String) {
		subLabel.text = text
	}
	
}

// MARK: - Setup UI
extension SettingCell {
	private func setupUI() {
		selectionStyle = .none
		
		// Icon
		contentView.addSubview(icon)
		icon.translatesAutoresizingMaskIntoConstraints = false
		icon.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
		icon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Padding.p20).isActive = true
		icon.widthAnchor.constraint(equalToConstant: iconSize.width).isActive = true
		icon.heightAnchor.constraint(equalToConstant: iconSize.height).isActive = true
		
		// Sub label
		contentView.addSubview(subLabel)
		subLabel.translatesAutoresizingMaskIntoConstraints = false
		subLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
		subLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Padding.p20).isActive = true
		subLabel.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.2).isActive = true
		
		// Main label
		contentView.addSubview(mainLabel)
		mainLabel.translatesAutoresizingMaskIntoConstraints = false
		mainLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
		mainLabel.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: Padding.p20).isActive = true
		mainLabel.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.6).isActive = true
	}
}
