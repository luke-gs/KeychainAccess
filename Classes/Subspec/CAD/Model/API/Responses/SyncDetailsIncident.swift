//
//  SyncDetailsIncident.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 29/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

// NOTE: This class has been generated from Diederik sample json. Will be updated once API is complete

/// Reponse object for a single Incident in the call to /sync/details
open class SyncDetailsIncident: Codable {
    open var number: String!
    open var secondaryCode: String!
    open var type: String!
    open var grade: IncidentGrade!
    open var patrolGroup: String!
    open var location : SyncDetailsLocation!
    open var createdAt: Date!
    open var lastUpdated: Date!
    open var details: String!
    open var informant : SyncDetailsInformant!
    open var associations : SyncDetailsIncidentAssociations!
    open var narrative: [SyncDetailsActivityLogItem]!
}

/// Response object for associations in an incident
open class SyncDetailsIncidentAssociations: Codable {
    open var persons : [SyncDetailsIncidentPerson]!
    open var vehicles : [SyncDetailsIncidentVehicle]!
}

/// Reponse object for a single vehicle in an incident
open class SyncDetailsIncidentVehicle: Codable {
    open var alertLevel : Int!
    open var vehicleDescription : String!
    open var vehicleType : String!
    open var color: String!
    open var bodyType: String!
    open var stolen: Bool!
    open var plateNumber : String!
}

/// Reponse object for a single person in an incident
open class SyncDetailsIncidentPerson: Codable {
    open var alertLevel: Int!
    open var dateOfBirth: String!
    
    open var firstName: String!
    open var middleNames: String!
    open var lastName: String!
    open var fullAddress: String!
    open var gender: String!
    open var thumbnail: String!
}

/// Reponse object for an informant in an incident
open class SyncDetailsInformant: Codable {
    open var fullName : String!
    open var primaryPhone : String!
    open var secondaryPhone : String!
}
