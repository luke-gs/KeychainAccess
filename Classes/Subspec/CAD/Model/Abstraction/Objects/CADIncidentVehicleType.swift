//
//  CADIncidentVehicleType.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 16/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// Protocol for a class representing an incident vehicle (association)
public protocol CADIncidentVehicleType: class {

    // MARK: - Network
    var alertLevel : Int? { get set }
    var bodyType: String? { get set }
    var color: String? { get set }
    var plateNumber : String? { get set }
    var stolen: Bool? { get set }
    var vehicleDescription : String? { get set }
    var vehicleType : String? { get set }
}
