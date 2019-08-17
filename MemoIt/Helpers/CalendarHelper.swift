//
//  CalendarHelper.swift
//  ScheMo
//
//  Created by MICA17 on 11/11/18.
//  Copyright © 2018 MC2. All rights reserved.
//

import UIKit

enum DateFormat: String {
    case dayMonthYear = "d MMMM yyyy"
    case dayMonth = "d MMMM"
    case monthYear = "MMMM yyyy"
    case year = "yyyy"
    case month = "MMMM"
    case day = "d"
    case weekday = "EEEE"
    case weekdayShort = "EEE"
    case hourMinute = "hh:mm"
    case weekdayDayMonth = "EEEE, d MMM"
    case event = "d MMM, yyyy    hh:mm"
    case full = "EEE d MMMM yyyy"
    case memoTime = "d/MMM/yyyy"
    case listReminder = "yyyy/MMM/d E HH:mm"
	
    var stringValue: String {
        return self.rawValue
    }
}

class CalendarHelper {
    
    // Day of week
    public static let dayofWeek: Int = 7
    
    // Date to String converter
    static func dateToString(date:Date, format:DateFormat) -> (String){
        let formatter = DateFormatter()
        formatter.dateFormat = format.stringValue
        return (formatter.string(from: date))
    }
    
    // Default collection view layout [Flow layout]
    static func defaultLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        
        let width: CGFloat = 25
        let height: CGFloat = 25
        layout.itemSize = CGSize(width: width, height: height)
        return layout
    }
    
    // Common week stack view
    static func weekdayStackView(byFont: UIFont, weekdayColor: UIColor?, weekendColor: UIColor?) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = 0
        let weekdayText = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        
        for text in weekdayText {
            let label = UILabel()
            label.textAlignment = .center
            label.minimumScaleFactor = 0.15
            label.adjustsFontSizeToFitWidth = true
            // Weekdays font
            label.font = byFont
            // Weekdays default color
            label.textColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)
            // Set to custom color, if avaliabel
            if let color = weekdayColor {
                label.textColor = color
            }
            // Weekday text
            label.text = text
            
            let weekCol = weekendColor ?? #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
            if label.text == "Sun" || label.text == "Sat" {
                label.textColor = weekCol
            }
            stackView.addArrangedSubview(label)
        }
        return stackView
    }
}
