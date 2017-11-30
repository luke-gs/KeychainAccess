//
//  SyncDetailsResource.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 29/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

// NOTE: This class has been generated from Diederik sample json. Will be updated once API is complete

/// Reponse object for a single Resource in the call to /sync/details
open class SyncDetailsResource: Codable {

    /// Enum for resource types
    public enum ResourceType: String, Codable {
        case vehicle = "Vehicle"
        case dogSquad = "DogSquad"

        public func icon() -> UIImage? {
            switch self {
            case .vehicle:
                return AssetManager.shared.image(forKey: .resourceCar)
            case .dogSquad:
                return AssetManager.shared.image(forKey: .resourceDog)
            }
        }
    }

    open var callsign : String!
    open var driver : String!
    open var equipment : [SyncDetailsResourceEquipment]!
    open var incidentNumber : String!
    open var lastUpdated : String!
    open var location : SyncDetailsLocation!
    open var payrollIds : [String]!
    open var remarks : String!
    open var shiftEnd : String!
    open var shiftStart : String!
    open var station : String!
    open var status : String!
    open var type : ResourceType!
    open var zone : String!
}

/// Reponse object for a single Equipment item in the resource
open class SyncDetailsResourceEquipment: Codable {
    open var count : Int!
    open var descriptionField : String!
}
