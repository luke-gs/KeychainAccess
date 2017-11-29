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
public struct SyncDetailsIncident: Codable {
    public var details : String!
    public var grade : String!
    public var incidentNumber : String!
    public var incidentType : String!
    public var informant : SyncDetailsInformant!
    public var location : SyncDetailsLocation!
    public var locations : [SyncDetailsLocation]!
    public var persons : [SyncDetailsIncidentPerson]!
    public var revisedType : String!
    public var severity : Int!
    public var status : String!
    public var vehicles : [SyncDetailsIncidentVehicle]!
    public var zone : String!
}

/// Reponse object for a single vehicle in an incident
public struct SyncDetailsIncidentVehicle: Codable {
    public var alertLevel : Int!
    public var associatedAlertLevel : Int!
    public var jurisdiction : String!
    public var make : String!
    public var plateNumber : String!
    public var registrationExpiryDate : String!
    public var registrationState : String!
    public var vehicleDescription : String!
    public var vehicleType : String!
}

/// Reponse object for a single person in an incident
public struct SyncDetailsIncidentPerson: Codable {
    public var alertLevel : Int!
    public var associatedAlertLevel : Int!
    public var dateOfBirth : String!
    public var familyName : String!
    public var gender : String!
    public var givenName : String!
    public var jurisdiction : String!
    public var middleNames : String!
    public var thumbnail : String!
    public var yearOnlyDateOfBirth : String!
}

/// Reponse object for an informant in an incident
public struct SyncDetailsInformant: Codable {
    public var fullName : String!
    public var primaryPhone : String!
    public var secondaryPhone : String!
}
