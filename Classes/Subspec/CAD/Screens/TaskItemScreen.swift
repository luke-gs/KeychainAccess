//
//  TaskItemScreen.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 26/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// Enum for all presentable CAD task item screens
public enum TaskItemScreen: Presentable {

    /// The landing screen of the task item, the top level split view
    case landing(viewModel: TaskItemViewModel)

    /// Allow changing the status of a resource, optionally linked to incident
    case resourceStatus(resource: CADResourceType, incident: CADIncidentType?)
}
