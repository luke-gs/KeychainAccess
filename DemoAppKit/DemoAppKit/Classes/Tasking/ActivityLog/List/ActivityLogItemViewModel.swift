//
//  ActivityLogItemViewModel.swift
//  ClientKit
//
//  Created by Trent Fitzgibbon on 28/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

/// View model for a single Activity Log item
open class ActivityLogItemViewModel {
    public let dotFillColor: UIColor
    public let dotStrokeColor: UIColor
    public let timestamp: Date
    public let title: String?
    public let subtitle: String?

    public init(dotFillColor: UIColor = .clear, dotStrokeColor: UIColor = .clear, timestamp: Date, title: String?, subtitle: String?) {
        self.dotFillColor = dotFillColor
        self.dotStrokeColor = dotStrokeColor
        self.timestamp = timestamp
        self.title = title
        self.subtitle = subtitle
    }

    public func dotImage() -> UIImage {
        return UIImage.statusDot(withColor: dotFillColor, strokeColor: dotStrokeColor)
    }
    
    /// Timestamp string
    open var timestampString: String {
        return ActivityLogItemViewModel.timestampDateFormatter.string(from: timestamp)
    }

    public static var timestampDateFormatter: DateFormatter = {
        return DateFormatter.preferredTimeStyle
    }()

}
