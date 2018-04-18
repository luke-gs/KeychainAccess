//
//  TaskItemScreen.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 26/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import UIKit

/// Enum for all presentable CAD task item screens
public enum TaskItemScreen: Presentable {

    /// The landing screen of the task item, the top level split view
    case landing(viewModel: TaskItemViewModel)

    /// Screen for changing the status of our resource, optionally linked to incident
    case resourceStatus(initialStatus: CADResourceStatusType?, incident: CADIncidentType?)

    /// Address popover for "Directions, Street View, Search"
    case addressLookup(source: UIView, coordinate: CLLocationCoordinate2D, address: String?)

    /// Show details for an association
    case associationDetails(association: CADIncidentAssociationType)

}
