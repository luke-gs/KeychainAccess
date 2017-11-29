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
public struct SyncDetailsResource: Codable {
    public var callsign : String!
    public var driver : String!
    public var equipment : [SyncDetailsResourceEquipment]!
    public var incidentNumber : String!
    public var lastUpdated : String!
    public var location : SyncDetailsLocation!
    public var payrollIds : [String]!
    public var remarks : String!
    public var shiftEnd : String!
    public var shiftStart : String!
    public var station : String!
    public var status : String!
    public var type : String!
    public var zone : String!
}

/// Reponse object for a single Equipment item in the resource
public struct SyncDetailsResourceEquipment: Codable {
    public var count : Int!
    public var descriptionField : String!
}
