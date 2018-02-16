//
//  SyncDetailsIncident.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 29/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import CoreLocation
import MPOLKit

// NOTE: This class has been generated from Diederik sample json. Will be updated once API is complete

/// Reponse object for a single Incident in the call to /sync/details
open class SyncDetailsIncident: Codable, CADIncidentType {
    open var identifier: String!
    open var secondaryCode: String!
    open var type: String!
    open var grade: IncidentGrade!
    open var patrolGroup: String!
    open var location : SyncDetailsLocation!
    open var createdAt: Date!
    open var lastUpdated: Date!
    open var details: String!
    open var informant : SyncDetailsIncidentInformant!
    open var locations: [SyncDetailsLocation]!
    open var persons: [SyncDetailsIncidentPerson]!
    open var vehicles: [SyncDetailsIncidentVehicle]!
    open var narrative: [SyncDetailsActivityLogItem]!

    // MARK: - Computed

    open var status: CADIncidentStatusType {
        if let resourceId = CADStateManager.shared.lastBookOn?.callsign,
            let resource = CADStateManager.shared.resourcesById[resourceId],
            let assignedIncidents = resource.assignedIncidents,
            assignedIncidents.contains(identifier)
        {
            if resource.currentIncident == identifier {
                return .current
            } else {
                return .assigned
            }
        } else if CADStateManager.shared.resourcesForIncident(incidentNumber: identifier).count > 0 {
            return .resourced
        } else {
            return .unresourced
        }
    }

    open var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: Double(location.latitude), longitude: Double(location.longitude))
    }

    open var resourceCount: Int {
        return CADStateManager.shared.resourcesForIncident(incidentNumber: identifier).count
    }

    open var resourceCountString: String? {
        return resourceCount > 0 ? "(\(resourceCount))" : nil
    }

    open var createdAtString: String {
        return DateFormatter.preferredDateTimeStyle.string(from: createdAt)
    }

}

