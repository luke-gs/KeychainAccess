//
//  TasksListItemViewModel.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 10/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public class TasksListItemViewModel {
    public let identifier: String
    public let title: String
    public let subtitle: String
    public let caption: String
    public let priority: String?
    public let description: String?
    public let resources: [TasksListItemResourceViewModel]?

    public var badgeText: String? {
        return priority
    }
    
    public let badgeTextColor: UIColor?
    public let badgeFillColor: UIColor?
    public let badgeBorderColor: UIColor?
    public var hasUpdates: Bool
    
    public init(identifier: String, title: String, subtitle: String, caption: String, priority: String? = nil, description: String? = nil, resources: [TasksListItemResourceViewModel]? = nil, badgeTextColor: UIColor?, badgeFillColor: UIColor?, badgeBorderColor: UIColor?, hasUpdates: Bool) {
        self.identifier = identifier
        self.title = title
        self.subtitle = subtitle
        self.caption = caption
        self.description = description
        self.resources = resources
        self.priority = priority
        self.badgeTextColor = badgeTextColor
        self.badgeFillColor = badgeFillColor
        self.badgeBorderColor = badgeBorderColor
        self.hasUpdates = hasUpdates
    }
}
