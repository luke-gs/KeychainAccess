//
//  SyncDetailsIncidentVehicle.swift
//  ClientKit
//
//  Created by Trent Fitzgibbon on 16/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

/// Reponse object for a single vehicle in an incident
open class SyncDetailsIncidentVehicle: Codable, CADIncidentVehicleType {

    public var alertLevel: Int!

    public var bodyType: String!

    public var color: String!

    public var plateNumber: String!

    public var stolen: Bool!

    public var vehicleDescription: String!

    public var vehicleType: String!

}

