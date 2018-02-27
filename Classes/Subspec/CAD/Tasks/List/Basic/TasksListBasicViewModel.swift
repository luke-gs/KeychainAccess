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

    public init(identifier: String, title: String?, subtitle: String?, caption: String?, description: String? = nil, hasUpdates: Bool = false) {
        self.description = description
        self.hasUpdates = hasUpdates
        super.init(identifier: identifier, title: title, subtitle: subtitle, caption: caption)
    }
    
    public convenience init(patrol: CADPatrolType, hasUpdates: Bool = false) {
        self.init(
            identifier: patrol.identifier,
            title: patrol.type,
            subtitle: patrol.location?.fullAddress,
            caption: "#\(patrol.identifier)",
            description: patrol.details,
            hasUpdates: hasUpdates)
    }
    
    
    public convenience init(broadcast: CADBroadcastType, hasUpdates: Bool = false) {
        self.init(
            identifier: broadcast.identifier,
            title: broadcast.title!,
            subtitle: broadcast.location?.suburb,
            caption: "#\(broadcast.identifier)",
            description: broadcast.details,
            hasUpdates: hasUpdates)
    }
}

