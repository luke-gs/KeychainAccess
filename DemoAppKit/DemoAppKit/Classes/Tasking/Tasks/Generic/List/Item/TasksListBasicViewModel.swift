//
//  TasksListBasicViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 13/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

/// A view model for the basic task list cell, where only title, subtitle, caption, and description are shown
open class TasksListBasicViewModel: TasksListItemViewModel {

    public let description: String?
    public var hasUpdates: Bool

    public init(identifier: String, source: CADTaskListSourceType, title: String?, subtitle: String?, caption: String?, description: String? = nil, hasUpdates: Bool = false) {
        self.description = description
        self.hasUpdates = hasUpdates
        super.init(identifier: identifier, source: source, title: title, subtitle: subtitle, caption: caption)
    }
    
    public convenience init(patrol: CADPatrolType, source: CADTaskListSourceType, hasUpdates: Bool = false) {
        self.init(
            identifier: patrol.identifier,
            source: source,
            title: patrol.type,
            subtitle: patrol.location?.fullAddress,
            caption: patrol.identifier,
            description: patrol.details,
            hasUpdates: hasUpdates)
    }
    
    
    public convenience init(broadcast: CADBroadcastType, source: CADTaskListSourceType, hasUpdates: Bool = false) {
        self.init(
            identifier: broadcast.identifier,
            source: source,
            title: broadcast.title!,
            subtitle: broadcast.location?.suburb,
            caption: broadcast.identifier,
            description: broadcast.details,
            hasUpdates: hasUpdates)
    }
}

