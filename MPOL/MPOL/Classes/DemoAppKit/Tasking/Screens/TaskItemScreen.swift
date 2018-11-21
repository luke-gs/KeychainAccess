//
//  TaskItemScreen.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 26/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import PublicSafetyKit

/// Enum for all presentable CAD task item screens
public enum TaskItemScreen: Presentable {

    /// The landing screen of the task item, the top level split view
    case landing(viewModel: TaskItemViewModel)

    /// Screen for changing the status of our resource, optionally linked to incident
    case resourceStatus(initialStatus: CADResourceStatusType?, incident: CADIncidentType?)

    /// Show details for an association
    case associationDetails(association: CADAssociationType)

}
