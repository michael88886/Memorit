//
//  Helper.swift
//  MemoIt
//
//  Created by mk mk on 6/6/19.
//  Copyright © 2019 MC2. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation
import MapKit

class Helper {
	// MARK: - File system functions
	// Create directory
	static func createDirectory(url: URL) {
		let fileManager = FileManager.default
		do {
			try fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
		} catch let error {
			print("Failed to create directory: ", error.localizedDescription)
		}
	}
	
	// Memo directory
	static func memoDirectory() -> URL {
		let fileManager = FileManager.default
		let docPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
		let memoPath = (docPath?.appendingPathComponent("Memo", isDirectory: true))!
		createDirectory(url: memoPath)
		return memoPath
	}
	
	// Image directory
	static func imageDirectory() -> URL {
		let memoPath = memoDirectory()
		let imagePath = memoPath.appendingPathComponent("Images", isDirectory: true)
		createDirectory(url: imagePath)
		return imagePath
	}
	
	// Audio directory
	static func audioDirectory() -> URL {
		let memoPath = memoDirectory()
		let audioPath = memoPath.appendingPathComponent("Audio", isDirectory: true)
		createDirectory(url: audioPath)
		return audioPath
	}
	
	// Clean temperary directory
	static func clearTmpDirectory() {
		do {
			let tmpDirURL = FileManager.default.temporaryDirectory
			let tmpDir = try FileManager.default.contentsOfDirectory(atPath: tmpDirURL.path)
			try tmpDir.forEach({ (file) in
				let fileURL = tmpDirURL.appendingPathComponent(file)
				try FileManager.default.removeItem(atPath: fileURL.path)
			})
		} catch let error {
			print("Can't clear tmp file")
			print(error.localizedDescription)
		}
	}
	
	// Unique name
	static func uniqueName() -> String {
		let accFactor: Double = 100 // Accuracy factor - avoid same unique ID from time interval
		let uniqueID: Double = Date().timeIntervalSince1970 * accFactor
		return String(Int(uniqueID))
	}
	
	// Cache image data
	static func cacheImageData(pngData: Data) -> URL? {
		var url: URL?
		do {
			let filename = uniqueName()
			let tmpPath = FileManager.default.temporaryDirectory
			var savedPath = tmpPath.appendingPathComponent(filename)
			savedPath.appendPathExtension("png")
			try pngData.write(to: savedPath)
			url = savedPath
		} catch let error {
			print("Failed to save image file: ", error.localizedDescription)
		}
		return url
	}
	
	// Get media duration in string
	static func mediaDuration(url: URL) -> String {
		// Get duration
		let audioAsset = AVURLAsset.init(url: url)
		let duration = audioAsset.duration
		
		// Convert time to string
		let timeInSecond = CMTimeGetSeconds(duration)
		let sInt = Int(timeInSecond)
		let second: Int = sInt % 60
		let minute: Int = (sInt / 60) % 60
		let hour: Int = sInt / 3600
		return String(format: "%02d:%02d:%02d", hour, minute, second)
	}
	
	// Convert time interval to string
	static func convertTimeToString(time: TimeInterval) -> String {
		let seconds = Int(time) % 60
		let minutes = (Int(time) / 60) % 60
		let hours = (Int(time) / 60 / 60) % 60
		return String(format: "%0.2d:%0.2d:%0.2d", hours, minutes, seconds)
	}
	
	
	// MARK: - Core data functions
	// Core data context
	static func dataContext() -> NSManagedObjectContext {
		// Get app delegate
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		// Data context
		return appDelegate.persistentContainer.viewContext
	}
	
	// MARK: - UIImage function
	static func normailzeOrientation(image: UIImage) -> UIImage {
		let orientation = image.imageOrientation
		let width = image.size.width
		let height = image.size.height
		let cgImage = image.cgImage
		
		if orientation == .up {
			// Normal orientation
			return image
		}
		
		// Calculate proper translation
		var transform:CGAffineTransform = CGAffineTransform.identity
		
		if orientation == .down || orientation == .downMirrored {
			transform = transform.translatedBy(x: width, y: height)
			transform = transform.rotated(by: CGFloat(Double.pi))
		}
		
		if orientation == .left || orientation == .leftMirrored {
			transform = transform.translatedBy(x: width, y: 0)
			transform = transform.rotated(by: CGFloat(Double.pi/2))
		}
		
		if orientation == .right || orientation == .rightMirrored {
			transform = transform.translatedBy(x: 0, y: height)
			transform = transform.rotated(by: CGFloat(-Double.pi/2))
		}
		
		if orientation == .upMirrored || orientation == .downMirrored {
			transform = transform.translatedBy(x: width, y: 0)
			transform = transform.scaledBy(x: -1.0, y: 1.0)
		}
		
		if orientation == .leftMirrored || orientation == .rightMirrored {
			transform = transform.translatedBy(x: height, y: 0)
			transform = transform.scaledBy(x: -1.0, y: 1.0)
		}
		
		// Draw underlaying CGImage into a new context and apply the transform
		let context: CGContext = CGContext(data: nil,
										   width: Int(width),
										   height: Int(height),
										   bitsPerComponent: cgImage!.bitsPerComponent,
										   bytesPerRow: 0,
										   space: cgImage!.colorSpace!,
										   bitmapInfo: cgImage!.bitmapInfo.rawValue)!
		context.concatenate(transform)
		
		if (orientation == .left || orientation == .leftMirrored ||
			orientation == .right || orientation == .rightMirrored) {
			context.draw(cgImage!, in: CGRect(origin: CGPoint.zero, size: CGSize(width: height, height: width)))
		}
		else {
			context.draw(cgImage!, in: CGRect(origin: CGPoint.zero, size: CGSize(width: width, height: height)))
		}
		
		// Create a new image from context
		let ctxCGImage = context.makeImage()!
		let finalImage = UIImage(cgImage: ctxCGImage)
		return finalImage
	}
	
	// Create image thumbnail
	static func imageThumbnail(image : UIImage, targetSize: CGSize, quality: CGFloat) -> UIImage? {
		UIGraphicsBeginImageContextWithOptions(targetSize, false, 0.0)
		image.draw(in: CGRect(origin: CGPoint.zero, size: targetSize))
		let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
		guard scaledImage != nil else { return nil }
		let imgData = scaledImage?.jpegData(compressionQuality: 0.5)
		UIGraphicsEndImageContext()
		return UIImage(data: imgData!)
	}
	
	// Error prompt
	static func errorPopup(withTitle: String, msg: String) -> UIAlertController {
		let alertC = UIAlertController(title: withTitle,
									   message: msg,
									   preferredStyle: .alert)
		alertC.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
			return
		}))
		return alertC
	}

}
