//
//  SyncDetailsIncidentVehicle.swift
//  ClientKit
//
//  Created by Trent Fitzgibbon on 16/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// Reponse object for a single vehicle in an incident
open class SyncDetailsIncidentVehicle: Codable, CADIncidentVehicleType {
    open var alertLevel : Int!
    open var vehicleDescription : String!
    open var vehicleType : String!
    open var color: String!
    open var bodyType: String!
    open var stolen: Bool!
    open var plateNumber : String!
}

