//
//  DateFormatter+Static.swift
//  MPOLKit
//
//  Created by Rod Brown on 19/5/17.
//
//

import Foundation

extension DateFormatter {
    
    public static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()
    
    public static let mediumNumericDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.setLocalizedDateFormatFromTemplate("ddMMyyyy")
        DateFormatter.isListeningForLocaleChanges = true
        return formatter
    }()
    
    
    // MARK: - Locale changes
    
    private static var isListeningForLocaleChanges: Bool = false {
        didSet {
            if isListeningForLocaleChanges && oldValue == false {
                NotificationCenter.default.addObserver(self, selector: #selector(mpl_currentLocaleDidChange), name: NSLocale.currentLocaleDidChangeNotification, object: nil)
            }
        }
    }
    
    @objc private class func mpl_currentLocaleDidChange() {
        mediumNumericDate.setLocalizedDateFormatFromTemplate("ddMMyyyy")
    }
    
}
