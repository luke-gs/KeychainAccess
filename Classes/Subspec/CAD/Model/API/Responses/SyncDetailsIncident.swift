//
//  SyncDetailsIncident.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 29/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import CoreLocation

// NOTE: This class has been generated from Diederik sample json. Will be updated once API is complete

/// Reponse object for a single Incident in the call to /sync/details
open class SyncDetailsIncident: Codable {
    // TODO: Change this to be some sort of extensible enum/class for client app overrides
    public enum Grade: String, Codable {
        case p1 = "P1"
        case p2 = "P2"
        case p3 = "P3"
        case p4 = "P4"
        
        public var color: UIColor {
            switch self {
            case .p1:
                return .orangeRed
            case .p2:
                return .sunflowerYellow
            case .p3:
                return .secondaryGray
            case .p4:
                return .secondaryGray
            }
        }
        
        public var filled: Bool {
            switch self {
            case .p1, .p2: return true
            case .p3, .p4: return false
            }
        }
    }
    
    // TODO: Change this to be some sort of extensible enum/class for client app overrides
    public enum Status: String, Codable {
        case resourced = "Resourced"
        case unresourced = "Unresourced"
        case current = "Current Incident"
        case assigned = "Assigned"
    }
    
    open var details : String!
    open var grade : Grade!
    open var incidentNumber : String!
    open var incidentType : String!
    open var informant : SyncDetailsInformant!
    open var location : SyncDetailsLocation!
    open var locations : [SyncDetailsLocation]!
    open var persons : [SyncDetailsIncidentPerson]!
    open var revisedType : String!
    open var severity : Int!
    open var vehicles : [SyncDetailsIncidentVehicle]!
    open var zone : String!
    
    // MARK: - Computed
    
    open var status: Status {
        if let resourceId = CADStateManager.shared.lastBookOn?.callsign,
            let resource = CADStateManager.shared.resourcesById[resourceId]
        {
            if resource.incidentNumber == incidentNumber {
                return .current
            } else {
                return .assigned
            }
        } else if CADStateManager.shared.resourcesForIncident(incidentNumber: incidentNumber).count > 0 {
            return .resourced
        } else {
            return .unresourced
        }
    }
    
    open var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: Double(location.latitude), longitude: Double(location.longitude))
    }
    
    open var resourceCount: Int {
        return CADStateManager.shared.resourcesForIncident(incidentNumber: incidentNumber).count
    }
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
