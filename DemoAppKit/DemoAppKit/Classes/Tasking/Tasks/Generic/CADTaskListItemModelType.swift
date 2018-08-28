//
//  CADTaskListItemModelType.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 22/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// Protocol for a model object that is used to create a task list item
public protocol CADTaskListItemModelType {

    /// Create a map annotation for the task list item if location is available
    func createAnnotation() -> TaskAnnotation?

}
