//
//  CADIncidentVehicleType.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 16/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// Protocol for a class representing an incident vehicle (association)
public protocol CADIncidentVehicleType: class, CADIncidentAssociationType {

    // MARK: - Network
    var alertLevel : CADAlertLevelType? { get set }
    var associatedAlertLevel: CADAlertLevelType? { get set }
    var primaryColour: String? { get set }
    var plateNumber : String? { get set }
    var vehicleDescription : String? { get set }
}
