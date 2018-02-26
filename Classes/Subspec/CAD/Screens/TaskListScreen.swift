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

    /// The landing screen of the task list, the top level split view
    case landing

    /// Create a new incident
    case createIncident

    /// Display the map filter
    case mapFilter(delegate: MapFilterViewControllerDelegate?)
}
