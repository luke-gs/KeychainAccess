//
//  TaskListScreen.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 26/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// Enum for all CAD task list screens that are presented
public enum TaskListScreen: Presentable {

    /// The top level split view
    case splitView

    /// Create a new incident
    case createIncident

    /// Display the map filter
    case mapFilter
}
