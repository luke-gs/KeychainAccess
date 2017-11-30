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
    open var details : String!
    open var grade : IncidentGrade!
    open var incidentNumber : String!
    open var incidentType : String!
    open var informant : SyncDetailsInformant!
    open var location : SyncDetailsLocation!
    open var locations : [SyncDetailsLocation]!
    open var persons : [SyncDetailsIncidentPerson]!
    open var revisedType : String!
    open var severity : Int!
    open var status : String!
    open var vehicles : [SyncDetailsIncidentVehicle]!
    open var zone : String!
}

/// Reponse object for a single vehicle in an incident
open class SyncDetailsIncidentVehicle: Codable {
    open var alertLevel : Int!
    open var associatedAlertLevel : Int!
    open var jurisdiction : String!
    open var make : String!
    open var plateNumber : String!
    open var registrationExpiryDate : String!
    open var registrationState : String!
    open var vehicleDescription : String!
    open var vehicleType : String!
}

/// Reponse object for a single person in an incident
open class SyncDetailsIncidentPerson: Codable {
    open var alertLevel : Int!
    open var associatedAlertLevel : Int!
    open var dateOfBirth : String!
    open var familyName : String!
    open var gender : String!
    open var givenName : String!
    open var jurisdiction : String!
    open var middleNames : String!
    open var thumbnail : String!
    open var yearOnlyDateOfBirth : String!
}

/// Reponse object for an informant in an incident
open class SyncDetailsInformant: Codable {
    open var fullName : String!
    open var primaryPhone : String!
    open var secondaryPhone : String!
}
