//
//  TasksListItemViewModel.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 10/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public class TasksListItemViewModel {
    public let title: String
    public let subtitle: String
    public let caption: String
    public let status: String?
    public let priority: String?
    public var boxText: String {
        return priority ?? ""
    }
    
    public let boxColor: UIColor
    public let boxFilled: Bool
    public var hasUpdates: Bool
    
    public init(title: String, subtitle: String, caption: String, status: String? = nil, priority: String? = nil, boxColor: UIColor, boxFilled: Bool, hasUpdates: Bool) {
        self.title = title
        self.subtitle = subtitle
        self.caption = caption
        self.status = status
        self.priority = priority
        self.boxColor = boxColor
        self.boxFilled = boxFilled
        self.hasUpdates = hasUpdates
    }
}
