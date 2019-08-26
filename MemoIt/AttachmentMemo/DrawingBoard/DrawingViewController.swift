//
//  DrawingViewController.swift
//  MemoIt
//
//  Created by mk mk on 20/8/19.
//  Copyright © 2019 MC2. All rights reserved.
//

import UIKit

class DrawingViewController: UIViewController {

	// MARK: - Properties
	// - Constants
	// Button tint color
	private let btnTintColor: UIColor = #colorLiteral(red: 0.370555222, green: 0.3705646992, blue: 0.3705595732, alpha: 1)
	// Tool height
	private let toolSize = CGSize(width: 60, height: 80)
	// Stack view height
	private let stackH: CGFloat = 24
	// Drawing colors
	private let colors = [#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), #colorLiteral(red: 0.6642242074, green: 0.6642400622, blue: 0.6642315388, alpha: 1), #colorLiteral(red: 1, green: 0.8039215686, blue: 0, alpha: 1), #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1), #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1), #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)]
	// Brush sizes
	private let brushSizes: [CGFloat] = [2.0, 4.0, 8.0, 10.0]
	
	
	// - Variables
	// Tools group
	private var toolGroup = [DrawingTool]()
	// Color group
	private var colorGroup = [UIButton]()
	// Brush size group
	private var brushGroup = [BrushSizeButton]()
	
	// - Save drawing
	var saveDrawing: ((UIImage) -> Void)?
	
	// MARK: - Views
	// Clear button
	private lazy var clearBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "ClearAll"), style: .plain, target: self, action: #selector(clearAll))
	// Undo button
	private lazy var undoBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "UndoBtn"), style: .plain, target: self, action: #selector(undo))
	// Redo button
	private lazy var redoBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "RedoBtn"), style: .plain, target: self, action: #selector(redo))
	
	// Pen
	private lazy var penView: PenView = {
		let pv = PenView()
		let tap = UITapGestureRecognizer(target: self, action: #selector(switchTool(_:)))
		pv.addGestureRecognizer(tap)
		return pv
	}()
	// Eraser
	private lazy var eraserView: EraserView = {
		let ev = EraserView()
		let tap = UITapGestureRecognizer(target: self, action: #selector(switchTool(_:)))
		ev.addGestureRecognizer(tap)
		return ev
	}() 
	
	// Drawing board
	private lazy var drawingBoard: DrawingBoard = {
		let db = DrawingBoard()
		db.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
		db.isOpaque = true
		
		// Shadow
		db.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).cgColor
		db.layer.shadowRadius = 4
		db.layer.shadowOpacity = 0.2
		db.layer.shadowOffset = .zero
		
		return db
	}()	
}

// MARK: - Override functions
extension DrawingViewController {
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Disable buttons
		clearBtn.isEnabled = false
		undoBtn.isEnabled = false
		redoBtn.isEnabled = false
		
		// Select pen tool
		penView.select()
		// Select color
		colorAction(colorGroup.first!)
		// Select brush size
		brushSizeAction(brushGroup.first!)
		
		// Setup drawing board
		drawingBoard.drawWidth(wdith: 2.0)
		drawingBoard.drawColor(color: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
	}
}

// MARK: - Private functions
extension DrawingViewController {
	// MARK: - Closuer functions
	// Drawing board empty
	private func drawingBoardEmpty(isEmpty: Bool) {
		clearBtn.isEnabled = !isEmpty
		undoBtn.isEnabled = !isEmpty
	}
	
	// Drawing cache empty
	private func drawingCacheEmpty(isEmpty: Bool) {
		redoBtn.isEnabled = !isEmpty
	}
	
	// MARK: - Misc function
	// Selection stack factory
	private func selectionStack() -> UIStackView {
		let stv = UIStackView ()
		stv.axis = .horizontal
		stv.distribution = .fillEqually
		stv.alignment = .center
		stv.spacing = 10
		return stv
	}
	
	// Update brush size
	private func updateBrushSize(size: CGFloat) {
		drawingBoard.drawWidth(wdith: size)
	}
	
	// Save drawing
	private func save(_ image: UIImage) {
		self.saveDrawing?(image)
	}
	
	// Drawing image avaliable
	private func drawimgImageAvaliable(enable: Bool) {
		print("img: \(enable)")
		clearBtn.isEnabled = enable
		undoBtn.isEnabled = enable
	}
	
	// Drawing cache avaliable
	private func drawingCacheAvaliable(enable: Bool) {
		print("cache: \(enable)")
		redoBtn.isEnabled = enable
	}
}


// MARK: - Actions
extension DrawingViewController {
	// Back action
	@objc private func backAction() {
		// If drawing board is not empty, save drawing
		if drawingBoard.isEmpty() == false {
			drawingBoard.saveDraw()
		}
		// Dismiss controller
		navigationController?.popViewController(animated: true)
	}
	
	// MARK: Color action
	@objc private func colorAction(_ sender: UIButton) {
		for btn in colorGroup {
			if sender === btn {
				btn.layer.borderColor = UIColor.white.cgColor
				if let color = sender.backgroundColor {
					drawingBoard.drawColor(color: color)
				}
			}
			else {
				btn.layer.borderColor = UIColor.clear.cgColor
			}
		}
	}
	
	// MARK: Brush size action
	@objc private func brushSizeAction(_ sender: BrushSizeButton) {
		for btn in brushGroup {
			if sender === btn {
				btn.select()
			}
			else {
				btn.deselect()
			}
		}
	}
	
	// MARK: Drawing board action
	// Clear all action
	@objc private func clearAll() {
		print("celear all")
		drawingBoard.clearAllDraw()
	}
	
	// Undo action
	@objc private func undo() {
		print("undo")
		drawingBoard.undoDraw()
	}
	
	// Redo action
	@objc private func redo() {
		print("redo")
		drawingBoard.redoDraw()
	}
	
	// MARK: Switch drawing tool action
	@objc private func switchTool(_ gesture: UITapGestureRecognizer) {
		guard let view = gesture.view else { return }
		if view === penView {
			penView.select()
			eraserView.deselect()
			
			// Update drawing board
			drawingBoard.drawBrush(brush: .pen)
		}
		else if view === eraserView {
			eraserView.select()
			penView.deselect()
			
			// Update drawing board
			drawingBoard.drawBrush(brush: .eraser)
		}
	}
}


// MARK: - Setup UI
extension DrawingViewController {
	override func loadView() {
		super.loadView()
		// Background color
		view.backgroundColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)
		
		// - Navigation buttons
		// Left button
		let leftBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "NaviBack44"), style: .plain, target: self, action: #selector(backAction))
		leftBtn.tintColor = btnTintColor
		navigationItem.leftBarButtonItem = leftBtn
		
		// Right
		let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
		let btns = [clearBtn, redoBtn, undoBtn, flexSpace]
		navigationItem.rightBarButtonItems = btns
		// Tint button
		for btn in btns { btn.tintColor = btnTintColor }
		
		// Bottom line
		let bottomLine = UIHelper.separator(withColor: #colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1))
		view.addSubview(bottomLine)
		bottomLine.translatesAutoresizingMaskIntoConstraints = false
		bottomLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
		bottomLine.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
		bottomLine.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
		bottomLine.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
		
		// Pen
		view.addSubview(penView)
		penView.translatesAutoresizingMaskIntoConstraints = false
		penView.bottomAnchor.constraint(equalTo: bottomLine.topAnchor).isActive = true
		penView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Padding.p10).isActive = true
		penView.widthAnchor.constraint(equalToConstant: toolSize.width).isActive = true
		penView.heightAnchor.constraint(equalToConstant: toolSize.height).isActive = true
		
		// Eraser
		view.addSubview(eraserView)
		eraserView.translatesAutoresizingMaskIntoConstraints = false
		eraserView.bottomAnchor.constraint(equalTo: bottomLine.topAnchor).isActive = true
		eraserView.leadingAnchor.constraint(equalTo: penView.trailingAnchor).isActive = true
		eraserView.widthAnchor.constraint(equalToConstant: toolSize.width).isActive = true
		eraserView.heightAnchor.constraint(equalToConstant: toolSize.height).isActive = true
		
		// Brush size
		let brushSizeStack = selectionStack()
		view.addSubview(brushSizeStack)
		brushSizeStack.translatesAutoresizingMaskIntoConstraints = false
		brushSizeStack.bottomAnchor.constraint(equalTo: bottomLine.topAnchor, constant: -Padding.p5).isActive = true
		brushSizeStack.leadingAnchor.constraint(equalTo: eraserView.trailingAnchor, constant: Padding.p20).isActive = true
		brushSizeStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Padding.p10).isActive = true
		brushSizeStack.heightAnchor.constraint(equalToConstant: UIHelper.defaultH).isActive = true
		
		// Brush stack - Add Subview
		for size in brushSizes {
			let btn = BrushSizeButton(brushSize: size)
			btn.brushSize = updateBrushSize
			btn.addTarget(self, action: #selector(brushSizeAction(_:)), for: .touchUpInside)
			brushSizeStack.addArrangedSubview(btn)
			brushGroup.append(btn)
			btn.translatesAutoresizingMaskIntoConstraints = false
			btn.heightAnchor.constraint(equalTo: brushSizeStack.heightAnchor).isActive = true
		}
		
		// Color Stack
		let colorStack = selectionStack()
		view.addSubview(colorStack)
		colorStack.translatesAutoresizingMaskIntoConstraints = false
		colorStack.bottomAnchor.constraint(equalTo: brushSizeStack.topAnchor, constant: -Padding.p10).isActive = true
		colorStack.leadingAnchor.constraint(equalTo: eraserView.trailingAnchor, constant: Padding.p20).isActive = true
		colorStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Padding.p10).isActive = true
		colorStack.heightAnchor.constraint(equalToConstant: stackH).isActive = true
		
		// Color stack - Add Subviews
		for color in colors {
			let btn = UIButton(type: .custom)
			btn.backgroundColor = color
			btn.addTarget(self, action: #selector(colorAction(_:)), for: .touchUpInside)
			btn.layer.cornerRadius = 6
			btn.layer.borderWidth = 3.0
			btn.layer.borderColor = UIColor.clear.cgColor
			btn.layer.shadowColor = UIColor.black.cgColor
			btn.layer.shadowOpacity = 0.2
			btn.layer.shadowRadius = 2
			btn.layer.shadowOffset = .zero
			colorStack.addArrangedSubview(btn)
			colorGroup.append(btn)
		}
		
		// Drawign board
		drawingBoard.isUserInteractionEnabled = true
		drawingBoard.drawingImageEmpty = drawimgImageAvaliable
		drawingBoard.drawingCacheEmpty = drawingCacheAvaliable
		drawingBoard.saveDrawing = save
		view.addSubview(drawingBoard)
		drawingBoard.translatesAutoresizingMaskIntoConstraints = false
		drawingBoard.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Padding.p20).isActive = true
		drawingBoard.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
		drawingBoard.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
		drawingBoard.bottomAnchor.constraint(equalTo: penView.topAnchor, constant: -Padding.p40).isActive = true
	}
}
