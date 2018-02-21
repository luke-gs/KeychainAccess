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
    public let title: String?
    public let subtitle: String?

    public func dotImage() -> UIImage {
        return UIImage.statusDot(withColor: dotFillColor, strokeColor: dotStrokeColor)
    }
    
    /// Timestamp string
    public var timestampString: String {
        return ActivityLogItemViewModel.timestampDateFormatter.string(from: timestamp)
    }

    public static var timestampDateFormatter: DateFormatter = {
        return DateFormatter.preferredTimeStyle
    }()

}
