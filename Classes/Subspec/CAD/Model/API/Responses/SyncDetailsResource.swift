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
    open var callsign: String!
    open var status: String!
    open var patrolGroup: String!
    open var station: String!
    open var currentIncident: String?
    open var assignedIncidents: [String]?
    open var location: SyncDetailsLocation?
    open var driver: String?
    open var payrollIds: [String]?
    open var shiftEnd: Date?
    open var shiftStart: Date?
    open var type: ResourceType!
    open var serial: String?
    open var vehicleCategory: String?
    open var equipment: [SyncDetailsResourceEquipment]?
    open var remarks : String?
    open var lastUpdated : Date?
    open var activityLog: [SyncDetailsActivityLogItem]?

    /// Status as a type that is client specific
    open var statusType: ResourceStatusType {
        get {
            return ClientModelTypes.resourceStatus.init(rawValue: status) ?? ClientModelTypes.resourceStatus.defaultCase
        }
        set {
            status = newValue.rawValue
        }
    }
}

/// Reponse object for a single Equipment item in the resource
open class SyncDetailsResourceEquipment: Codable {
    open var count: Int!
    open var description: String!

    public init(count: Int!, description: String!) {
        self.count = count
        self.description = description
    }

    /// Copy constructor
    public init(equipment: SyncDetailsResourceEquipment) {
        self.count = equipment.count
        self.description = equipment.description
    }
}
