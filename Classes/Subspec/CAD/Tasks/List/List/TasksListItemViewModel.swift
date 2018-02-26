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
    open let identifier: String
    open let source: CADTaskListSourceType
    open let title: String?
    open let subtitle: String?
    open let caption: String?

    public init(identifier: String, source: CADTaskListSourceType, title: String?, subtitle: String?, caption: String?) {
        self.identifier = identifier
        self.source = source
        self.title = title
        self.subtitle = subtitle
        self.caption = caption
    }
}
