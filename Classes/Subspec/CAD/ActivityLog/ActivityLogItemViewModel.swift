//
//  ActivityLogItemViewModel.swift
//  ClientKit
//
//  Created by Trent Fitzgibbon on 28/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

/// View model for a single Activity Log item
public struct ActivityLogItemViewModel {
    public let dotFillColor: UIColor
    public let dotStrokeColor: UIColor
    public let timestamp: Date
    public let title: String
    public let subtitle: String

    public func dotImage() -> UIImage {
        return UIImage.statusDot(withColor: dotFillColor, strokeColor: dotStrokeColor)
    }
    
    /// Timestamp string
    public var timestampString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "HH:mm"
        
        return dateFormatter.string(from: timestamp)
    }
}
