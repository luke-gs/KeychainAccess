//
//  TasksListItemViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 19/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// Base class for a task list item view model
open class TasksListItemViewModel {
    public let identifier: String
    public let source: CADTaskListSourceType
    public let title: String?
    public let subtitle: String?
    public let caption: String?

    public init(identifier: String, source: CADTaskListSourceType, title: String?, subtitle: String?, caption: String?) {
        self.identifier = identifier
        self.source = source
        self.title = title
        self.subtitle = subtitle
        self.caption = caption
    }

    /// Create the task item details view model from this list item
    open func createItemViewModel() -> TaskItemViewModel? {
        return source.createItemViewModel(identifier: identifier)
    }

}
