//
//  CADIncidentCore.swift
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
open class CADIncidentCore: Codable, CADIncidentType {

    // MARK: - Network

    public var identifier: String!

    public var secondaryCode: String!

    public var type: String!

    public var grade: CADIncidentGradeType!

    public var patrolGroup: String!

    public var location: CADLocationType!

    public var createdAt: Date!

    public var lastUpdated: Date!

    public var details: String!

    public var informant: CADIncidentInformantType!

    public var locations: [CADLocationType]!

    public var persons: [CADIncidentPersonType]!

    public var vehicles: [CADIncidentVehicleType]!

    public var narrative: [CADActivityLogItemType]!

    // MARK: - Generated

    open var statusType: CADIncidentStatusType {
        if let resourceId = CADStateManager.shared.lastBookOn?.callsign,
            let resource = CADStateManager.shared.resourcesById[resourceId],
            let assignedIncidents = resource.assignedIncidents,
            assignedIncidents.contains(identifier)
        {
            if resource.currentIncident == identifier {
                return IncidentStatusCore.current
            } else {
                return IncidentStatusCore.assigned
            }
        } else if CADStateManager.shared.resourcesForIncident(incidentNumber: identifier).count > 0 {
            return IncidentStatusCore.resourced
        } else {
            return IncidentStatusCore.unresourced
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

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case createdAt = "createdAt"
        case details = "details"
        case grade = "grade"
        case identifier = "identifier"
        case informant = "informant"
        case lastUpdated = "lastUpdated"
        case location = "location"
        case locations = "locations"
        case narrative = "narrative"
        case patrolGroup = "patrolGroup"
        case persons = "persons"
        case secondaryCode = "secondaryCode"
        case type = "type"
        case vehicles = "vehicles"
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        createdAt = try values.decodeIfPresent(Date.self, forKey: .createdAt)
        details = try values.decodeIfPresent(String.self, forKey: .details)
        grade = try values.decodeIfPresent(IncidentGradeCore.self, forKey: .grade)
        identifier = try values.decodeIfPresent(String.self, forKey: .identifier)
        informant = try values.decodeIfPresent(CADIncidentInformantCore.self, forKey: .informant)
        lastUpdated = try values.decodeIfPresent(Date.self, forKey: .lastUpdated)
        location = try values.decodeIfPresent(CADLocationCore.self, forKey: .location)
        locations = try values.decodeIfPresent([CADLocationCore].self, forKey: .locations)
        narrative = try values.decodeIfPresent([CADActivityLogItemCore].self, forKey: .narrative)
        patrolGroup = try values.decodeIfPresent(String.self, forKey: .patrolGroup)
        persons = try values.decodeIfPresent([CADIncidentPersonCore].self, forKey: .persons)
        secondaryCode = try values.decodeIfPresent(String.self, forKey: .secondaryCode)
        type = try values.decodeIfPresent(String.self, forKey: .type)
        vehicles = try values.decodeIfPresent([CADIncidentVehicleCore].self, forKey: .vehicles)
    }

    public func encode(to encoder: Encoder) throws {
        MPLUnimplemented()
    }

}

