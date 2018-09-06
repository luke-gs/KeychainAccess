//
//  CADIncidentCore.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 29/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import CoreLocation

/// PSCore implementation of class representing an incident task
open class CADIncidentCore: Codable, CADIncidentDetailsType {

    // MARK: - Network

    open var identifier: String
    
    open var incidentNumber: String

    open var secondaryCode: String?

    open var type: String?

    open var grade: CADIncidentGradeType

    open var patrolGroup: String?

    open var location: CADLocationType?

    open var createdAt: Date?

    open var lastUpdated: Date?

    open var details: String?

    open var informant: CADIncidentInformantType?

    open var locations: [CADLocationType]

    open var persons: [CADPersonType]

    open var vehicles: [CADVehicleType]

    open var narrative: [CADActivityLogItemType]

    // MARK: - Generated

    open var status: CADIncidentStatusType {
        if let resourceId = CADStateManager.shared.lastBookOn?.callsign,
            let resource = CADStateManager.shared.resourcesById[resourceId],
            resource.assignedIncidents.contains(identifier)
        {
            if resource.currentIncident == identifier {
                return CADIncidentStatusCore.current
            } else {
                return CADIncidentStatusCore.assigned
            }
        } else if CADStateManager.shared.resourcesForIncident(incidentNumber: identifier).count > 0 {
            return CADIncidentStatusCore.resourced
        } else {
            return CADIncidentStatusCore.unresourced
        }
    }

    open var coordinate: CLLocationCoordinate2D? {
        return location?.coordinate
    }

    open var resourceCount: Int {
        return CADStateManager.shared.resourcesForIncident(incidentNumber: identifier).count
    }

    open var resourceCountString: String? {
        return resourceCount > 0 ? "(\(resourceCount))" : nil
    }

    open var createdAtString: String? {
        return createdAt?.asPreferredDateTimeString()
    }

    // MARK: - CADTaskListItemModelType

    /// Create a map annotation for the task list item if location is available
    open func createAnnotation() -> TaskAnnotation? {
        guard let coordinate = coordinate else { return nil }
        return IncidentAnnotation(identifier: incidentNumber,
                                  source: CADTaskListSourceCore.incident,
                                  coordinate: coordinate,
                                  title: type,
                                  subtitle: resourceCountString,
                                  badgeText: grade.title,
                                  badgeTextColor: grade.badgeColors.text,
                                  badgeFillColor: grade.badgeColors.fill,
                                  badgeBorderColor: grade.badgeColors.border,
                                  usesDarkBackground: status.useDarkBackgroundOnMap,
                                  priority: grade)
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
        grade = try values.decodeIfPresent(CADIncidentGradeCore.self, forKey: .grade) ?? .p4
        identifier = try values.decode(String.self, forKey: .identifier)
        // TODO: Model should probably be changed for separate ID and incident no.
        incidentNumber = try values.decode(String.self, forKey: .identifier)
        informant = try values.decodeIfPresent(CADIncidentInformantCore.self, forKey: .informant)
        lastUpdated = try values.decodeIfPresent(Date.self, forKey: .lastUpdated)
        location = try values.decodeIfPresent(CADLocationCore.self, forKey: .location)
        locations = try values.decodeIfPresent([CADLocationCore].self, forKey: .locations) ?? []
        narrative = try values.decodeIfPresent([CADActivityLogItemCore].self, forKey: .narrative) ?? []
        patrolGroup = try values.decodeIfPresent(String.self, forKey: .patrolGroup)
        persons = try values.decodeIfPresent([CADIncidentPersonCore].self, forKey: .persons) ?? []
        secondaryCode = try values.decodeIfPresent(String.self, forKey: .secondaryCode)
        type = try values.decodeIfPresent(String.self, forKey: .type)
        vehicles = try values.decodeIfPresent([CADIncidentVehicleCore].self, forKey: .vehicles) ?? []
    }

    public func encode(to encoder: Encoder) throws {
        MPLUnimplemented()
    }

}

